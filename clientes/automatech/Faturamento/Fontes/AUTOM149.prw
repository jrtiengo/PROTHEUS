#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM149.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Jean Rehermann                                                      *
// Data......: 15/01/2013                                                          *
// Objetivo..: Gravação do pedido de comissionamento                               *
//             Programa que efetua a criação  de  pedido  de  vendas  de  comissão *
//             quando o pedido referente a este faturamento for  do  tipo  externo *
//            (pedido de intermediação) referente à tarefa #1065 do portfólio.     *
//             Chamado pelo ponto de entrada M460FIM (fonte PE_M460FIM.PRW)        *
// ------------------------------------------------------------------------------- *
// No dia 15/01/2013, foi alterado este programa conforme  solicitação  da  tarefa *
// interna de nº 260 onde deverá ser aberto a quantidade de  pedidos  de comissões *
// quantos forem as parcelas da condição de pagamento utilizada no pedido de inter-*
// merdiação.                                                                      *
//**********************************************************************************

User Function AUTOM149( _Vencimento, _Valor, _Parcelas)

	Local _cNewNumPV   := ""
	Local _cProduto    := ""
	Local _lMsErroAuto := .F.
	Local _Pabertura   := SC5->C5_NUM
	Local _cPedido     := SC5->C5_NUM
    Local _Emissao     := SC5->C5_EMISSAO
    Local _Cliente     := SC5->C5_CLIENTE
    Local _LojaCli     := SC5->C5_LOJACLI
    Local _Condicao    := SC5->C5_CONDPAG
    Local cNota        := ""
    Local cSerie       := ""
    Local cSerLido     := ""
    Local nCarne       := 0
    Local cGravar      := ""
    Local nDifBase     := 0
    Local nDifComi     := 0
	Local _nTotFat     := _nTotCom := 0
	Local _aCabec      := {}
	Local _aItens      := {}
	Local _aItem       := {}
	Local _aVend       := {}
	Local _cProd       := SuperGetMV("AUT_PROINT", ,"004604") // Produto referente à comissão
	Local _cTes        := SuperGetMV("AUT_TESINT", ,"718")    // Tes de serviço
    Local cSql         := "" 
    Local nContar      := 0
    Local aComissao    := {}
    Local aCondicao    := {}
    Local nTcomissao   := 0
    Local nTprodutos   := 0   
    Local nDataFatur   := Ctod("  /  /    ")
    Local j            := ""
    Local __Condicao   := ""

    Local cPVOrigem    := SC5->C5_NUM
    Local cPVDestino   := ""

    Private oDlgF

    Private cCodFor	   := Space(06)
    Private cLojFor	   := Space(03)
    Private cNomFor    := Space(40)
    Private lChumba    := .F.
    Private oGet1
    Private oGet2
    Private oGet3
    
	Private	_aAreaXXX := GetArea()
	Private _aAreaSC5 := SC5->( GetArea() )
	Private _aAreaSC6 := SC6->( GetArea() )
    Private _aAreaSE3 := SE3->( GetArea() )

    U_AUTOM628("AUTOM149")
	
    // Inicializa o array com os vendedores do pedido de intermediação
    // Código do Vendedor, % de comissão, Base de Comissão, Valor da Comissão
    aAdd( _aVend, { SC5->C5_VEND1, 0, 0, 0 } )
    aAdd( _aVend, { SC5->C5_VEND2, 0, 0, 0 } )
    aAdd( _aVend, { SC5->C5_VEND3, 0, 0, 0 } )
     aAdd( _aVend, { SC5->C5_VEND4, 0, 0, 0 } )        
    aAdd( _aVend, { SC5->C5_VEND5, 0, 0, 0 } )
    
    // Pesquisa o novo código do pedido a ser incluído
    _cNewNumPV := GetSxeNum( "SC5", "C5_NUM" )
    cPVDestino := _cNewNumPV

    // Consiste se o cadastro do fornecedor externo está coerente com o cadastro de clientes

    // Fornecedor
    If Select("T_FORNECEDOR") > 0
       T_FORNECEDOR->( dbCloseArea() )
    EndIf

    cSql := "SELECT A1_COD , "
    cSql += "       A1_LOJA, "
    cSql += "       A1_NOME, "
    cSql += "       A1_CGC   "
    cSql += "  FROM " + RetSqlName("SA1")
    cSql += " WHERE A1_COD     = '" + Alltrim(SC5->C5_FORNEXT) + "'"
    cSql += "   AND A1_LOJA    = '" + Alltrim(SC5->C5_LOJAEXT) + "'"
    cSql += "   AND D_E_L_E_T_ = ''
   
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

    // Cliente
    If Select("T_CLIENTE") > 0
       T_CLIENTE->( dbCloseArea() )
    EndIf

    cSql := "SELECT A1_COD , "
    cSql += "       A1_LOJA, "
    cSql += "       A1_NOME, "
    cSql += "       A1_CGC   "
    cSql += "  FROM " + RetSqlName("SA1")
    cSql += " WHERE A1_COD     = '" + Alltrim(SC5->C5_CLIENTE) + "'"
    cSql += "   AND A1_LOJA    = '" + Alltrim(SC5->C5_LOJACLI) + "'"
    cSql += "   AND D_E_L_E_T_ = ''
   
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

    If ALLTRIM(T_CLIENTE->A1_CGC) <> Alltrim(T_FORNECEDOR->A1_CGC)
    
       DEFINE MSDIALOG oDlgF TITLE "Informaçlão de Fornecedor" FROM C(178),C(181) TO C(365),C(606) PIXEL

       @ C(005),C(005) Say "Atenção!"                                                                          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
       @ C(018),C(005) Say "O Fornecedor informado no pedido de venda não corresponde ao cadastro de cliente." Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
       @ C(026),C(005) Say "O CNPJ do Cliente foi verificado com o CNPJ do Fornecedor."                        Size C(145),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
       @ C(034),C(005) Say "Indique o Fornecedor para continuar o processo."                                   Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
       @ C(047),C(005) Say "Fornecedor"                                                                        Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgF

       @ C(058),C(005) MsGet oGet1 Var cCodFor              Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF F3("SA1") VALID(PSQFORPV(cCodFor, cLojFor))
       @ C(058),C(034) MsGet oGet2 Var cLojFor              Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF           VALID(PSQFORPV(cCodFor, cLojFor))
       @ C(058),C(053) MsGet oGet3 Var cNomFor When lChumba Size C(152),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF

       @ C(075),C(086) Button "Continuar ..." Size C(037),C(012) PIXEL OF oDlgF ACTION( ENCJANFOR() )

       ACTIVATE MSDIALOG oDlgF CENTERED 
    
    Else
      
       cCodFor := SC5->C5_FORNEXT
       cLojFor := SC5->C5_LOJAEXT
    
    Endif

    // Posiciona na tabela de ítens do pedido de venda
   	dbSelectArea("SC6")
	dbSetOrder(1)

	If dbSeek( xFilial("SC6") + SC5->C5_NUM )

	   While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC5->C5_NUM

          // Calcula o valor do novo pedido de venda
          _Automatech := Round((SC6->C6_COMIAUT / _Parcelas),2)
          _Valor      := Round((SC6->C6_VALOR   / _Parcelas),2)				
             
	      _aItem := {}
	  	  _cProduto := IIf( Empty( _cProd ), SC6->C6_PRODUTO, _cProd )
	
	      aAdd( _aItem, { "C6_FILIAL" , xFilial("SC6")  , NIL } ) // Filial
		  aAdd( _aItem, { "C6_NUM"    , _cNewNumPV      , NIL } ) // Número do Pedido
		  aAdd( _aItem, { "C6_ITEM"   , SC6->C6_ITEM    , NIL } ) // Número do Item no Pedido
		  aAdd( _aItem, { "C6_PRODUTO", _cProduto       , NIL } ) // Código do Produto
		  aAdd( _aItem, { "C6_QTDVEN" , 1               , NIL } ) // Quantidade Vendida
		  aAdd( _aItem, { "C6_PRCVEN" , _Automatech     , NIL } ) // Preço Unitário Líquido
		  aAdd( _aItem, { "C6_VALOR"  , _Automatech     , NIL } ) // Valor Total do Item
		  aAdd( _aItem, { "C6_ENTREG" , dDataBase       , NIL } ) // Data da Entrega
		  aAdd( _aItem, { "C6_UM"     , SC6->C6_UM      , NIL } ) // Unidade de Medida Primária
		  aAdd( _aItem, { "C6_TES"    , _cTes           , NIL } ) // Tipo de Entrada/Saida do Item
		  aAdd( _aItem, { "C6_CLI"    , SC5->C5_FORNEXT , NIL } ) // Cliente
		  aAdd( _aItem, { "C6_LOJA"   , SC5->C5_LOJAEXT , NIL } ) // Loja do Cliente
	
 		  aAdd( _aItens, _aItem )
				
          // Carrega as comissões dos vendedores

          // Vendedor 1
          If SC6->C6_COMIS1 <> 0
             _aVend[1,3] := _aVend[1,3] + _Valor
             _aVend[1,4] := Round(_aVend[1,4] + (_Valor * SC6->C6_COMIS1) / 100,2)
          Endif
             
          // Vendedor 2
          If SC6->C6_COMIS2 <> 0
             _aVend[2,3] := _aVend[2,3] + _Valor
             _aVend[2,4] := Round(_aVend[2,4] + (_Valor * SC6->C6_COMIS2) / 100,2)
          Endif
                
          // Vendedor 3
          If SC6->C6_COMIS3 <> 0
             _aVend[3,3] := _aVend[3,3] + _Valor
             _aVend[3,4] := Round(_aVend[3,4] + (_Valor * SC6->C6_COMIS3) / 100,2)
          Endif

          // Vendedor 4
          If SC6->C6_COMIS4 <> 0
             _aVend[4,3] := _aVend[4,3] + _valor
             _aVend[4,4] := Round(_aVend[4,4] + (_Valor * SC6->C6_COMIS4) / 100,2)
          Endif

          // Vendedor 5
          If SC6->C6_COMIS5 <> 0
             _aVend[5,3] := _aVend[5,3] + _Valor
             _aVend[5,4] := Round(_aVend[5,4] + (_Valor * SC6->C6_COMIS5) / 100,2)
          Endif

          SC6->( dbSkip() )

	   EndDo
		
    EndIf
		
    // Atualizada o percentual das comissões dos vendedores
    For _nX := 1 to 5
        _aVend[_nX,2] := Round((_aVend[_nX,4] * 100) / _aVend[_nX,3],2)
    Next _nX    
		
    // Monta os dados para o cabeçalho do pedido
	aAdd( _aCabec, { "C5_FILIAL" , xFilial("SC5") , NIL } )
	aAdd( _aCabec, { "C5_NUM"    , _cNewNumPV     , NIL } )
	aAdd( _aCabec, { "C5_TIPO"   , "N"            , NIL } )
//	aAdd( _aCabec, { "C5_CLIENTE", SC5->C5_FORNEXT, NIL } )
//	aAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJAEXT, NIL } )

	aAdd( _aCabec, { "C5_CLIENTE", cCodFor        , NIL } )
	aAdd( _aCabec, { "C5_LOJACLI", cLojFor        , NIL } )

	aAdd( _aCabec, { "C5_TIPOCLI", "F"            , NIL } )
	aAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, NIL } )
    aAdd( _aCabec, { "C5_VEND1"  , _aVend[ 1, 1 ] , NIL } )
	aAdd( _aCabec, { "C5_VEND2"  , _aVend[ 2, 1 ] , NIL } )
	aAdd( _aCabec, { "C5_VEND3"  , _aVend[ 3, 1 ] , NIL } )
	aAdd( _aCabec, { "C5_VEND4"  , _aVend[ 4, 1 ] , NIL } )
	aAdd( _aCabec, { "C5_VEND5"  , _aVend[ 5, 1 ] , NIL } )
	aAdd( _aCabec, { "C5_COMIS1" , _aVend[ 1, 2 ] , NIL } )
	aAdd( _aCabec, { "C5_COMIS2" , _aVend[ 2, 2 ] , NIL } )
	aAdd( _aCabec, { "C5_COMIS3" , _aVend[ 3, 2 ] , NIL } )
	aAdd( _aCabec, { "C5_COMIS4" , _aVend[ 4, 2 ] , NIL } )
	aAdd( _aCabec, { "C5_COMIS5" , _aVend[ 5, 2 ] , NIL } )
	aAdd( _aCabec, { "C5_EMISSAO", dDataBase      , NIL } )
	aAdd( _aCabec, { "C5_TIPLIB" , "2"            , NIL } )
	aAdd( _aCabec, { "C5_TPFRETE", "C"            , NIL } )
	
    // Rotina automática para inclusão do pedido de vendas.
    MsExecAuto( { |x,y,z| Mata410( x, y, z ) }, _aCabec, _aItens, 3 ) 
	
	If !_lMsErroAuto

       // Confirma o número do pedido
	   ConfirmSX8() 

       // Abre registro na tabela SE3 (Comissões) para os vendedores
       If Select("T_COMISSAO") > 0
          T_COMISSAO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT C6_DATFAT,"
       cSql += "       C6_NOTA   "
       cSql += "  FROM " + RetSqlName("SC6")
       cSql += " WHERE C6_NUM       = '" + Alltrim(_cPedido)       + "'"
       cSql += "   AND C6_FILIAL    = '" + Alltrim(xFilial("SC5")) + "'"
       cSql += "   AND R_E_C_D_E_L_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

       cNota      := T_COMISSAO->C6_NOTA
       nDataFatur := Ctod(Substr(T_COMISSAO->C6_DATFAT,07,02) + "/" + ;
                          Substr(T_COMISSAO->C6_DATFAT,05,02) + "/" + ;
                          Substr(T_COMISSAO->C6_DATFAT,01,04))
       Do Case
          Case Alltrim(xFilial("SC5")) == "01"
               cSerie := "P1"
          Case Alltrim(xFilial("SC5")) == "02"
               cSerie := "P2"
          Case Alltrim(xFilial("SC5")) == "03"
               cSerie := "P3"
       EndCase                           

       // Abre registros de comissão na Tabela E3 para os vendedores do pedido de intermediação
       For nAbrir = 1 to Len(_aVend)            

           If Empty(Alltrim(_aVend[nAbrir,1])) 
              Loop
           Endif

           DbSelectArea("SE3")
           DbAppend(.F.)
           SE3->E3_FILIAL  := xFilial("SC5")
           SE3->E3_VEND    := _aVend[nAbrir,1]
           SE3->E3_NUM     := cNota
           SE3->E3_CODCLI  := _Cliente
           SE3->E3_LOJA    := _LojaCli 
           SE3->E3_SERIE   := cSerie
           SE3->E3_PREFIXO := "P1"
           SE3->E3_BASE    := _aVend[nAbrir,3]
           SE3->E3_PORC    := _aVend[nAbrir,2]
           SE3->E3_COMIS   := _aVend[nAbrir,4]
           SE3->E3_EMISSAO := dDataBase
           SE3->E3_VENCTO  := _Vencimento
           SE3->E3_PVORIG  := _cPedido
           SE3->E3_PEDIDO  := _cNewNumPV

           DbUnlock()
              
       Next nAbrir

       // Linka os pedidos entre si pela gravação do campo C5_PVEXTER
       dbSelectArea("SC5")
	   dbSetOrder(1)
	   If dbSeek( xFilial("SC5") + cPVOrigem )
	      Reclock("SC5",.F.)
		  C5_PVEXTERN := cPVDestino
		  MsUnlock()
	   Endif
			   
   	   dbSelectArea("SC5")
	   dbSetOrder(1)
	   If dbSeek( xFilial("SC5") + cPVDestino )
	      Reclock("SC5",.F.)
	      C5_PVEXTERN := cPVOrigem
	      MsUnlock()
	   Endif

    Else

  	   If MsgYesNo("Ocorreu um problema na criação do pedido de comissão. Deseja exibir o erro?")
	 	  MostraErro() // Exibe tela indicando qual o erro ocorrrido
	   EndIf

	   RollBackSX8() // Retorna o número para o controle do SXE

   	   RestArea( _aAreaSC6 )
	   RestArea( _aAreaSC5 )
	   RestArea( _aAreaXXX )
	   RestArea( _aAreaSE3 )

       Return( Nil )

	EndIf
	   
	RestArea( _aAreaSC6 )
	RestArea( _aAreaSC5 )
	RestArea( _aAreaXXX )
	RestArea( _aAreaSE3 )

Return( Nil )

// Função que pesquisa o grupo informado
Static Function PsqForPV(_Codigo, _Loja)

   Local cSql := ""
   
   If Empty(Alltrim(_Codigo))
      cNomFor   := Space(40)
      Return(.T.)
   Endif

   If Empty(Alltrim(_Codigo))
      cNomFor   := Space(40)
      Return(.T.)
   Endif

   If Select("T_CADASTRO") > 0
      T_CADASTRO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME"
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(_Codigo) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(_Loja)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

   If T_CADASTRO->( EOF() )
      cCodFor := Space(06)
      cLojFor := Space(03)
      cNomFor := Space(40)
   Else
      cNomFor := T_CADASTRO->A1_NOME
   Endif
      
Return(.T.)

// Função que encerra a janela de pesquisa do fornecedor
Static Function ENCJANFOR()

   If Empty(Alltrim(cCodFor)) .And. Empty(Alltrim(cLojFor))
      Msgalert("Fornecedor não informado. Verifique!")
      Return(.T.)
   Endif

   oDlgF:End() 
   
Return(.T.)