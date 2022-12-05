#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM162.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/03/2013                                                          *
// Objetivo..: Gatilho que verifica se transportadora foi informada na  digitação  *
//             dos produtos da proposta comercial. Calcula também o valor do fre-  *
//             te pelo Site dos Correios por produto informado na proposta comer-  *
//             cial.                                                               *
// Parâmetros: < _Chamado > Indica por onde o gatilho foi chamado:                 *
//             1 - Pelo código do produto da proposta comerial                     *
//                 Por  este tipo somente verificará se a transportadora foi  in-  *
//                 formada.                                                        *
//             2 - Pela quantidade do produto. Aqui onde será calculado  o  valor  *
//                 do frete pela soma dos valor de frete dos produtos.             *
//             < Campo    > Indica de que campo foi disparado o  gatilho.  Isso é  *
//                 necessário para saber que conteúdo deve ser retornado.          *
//                 C = Campo Código                                                *
//                 Q = Campo Quantidade                                            * 
//**********************************************************************************

User Function AUTOM162( _Chamado, _Campo )

   Local nContar      := 0
   Local _Pos_Atual   := n
   Local _vFrete      := 0
   Local _Retorno     := IIF( _Campo   == "C" , "", 0 )
   Local _Transporte  := IIF( _Chamado == "PC", M->ADY_TRANSP, M->C5_TRANSP )
   Local _TipoFrete   := IIF( _Chamado == "PC", M->ADY_TPFRET, M->C5_TPFRET )
   Local _POS_PRODUTO := ""
   Local _POS_PARNUM  := ""
   Local _POS_DESCRI  := ""
   Local _POS_UNIDADE := ""
   Local _POS_QUANTI  := 0
   Local _POS_PRCTAB  := 0

   U_AUTOM628("AUTOM162")

   If _Chamado == "PC"

      _POS_PRODUTO := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_PRODUT" } )
      _POS_PARNUM  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_PARNUM" } )
      _POS_DESCRI  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_DESCRI" } )
      _POS_UNIDADE := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_UM"     } )
      _POS_QUANTI  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_QTDVEN" } )            
      _POS_PRCTAB  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "ADZ_PRCTAB" } )            

      If M->ADY_TPFRET <> "C"
         M->ADY_FRETE := 0
         M->ADY_FCOR  := 0
      Endif   

   Else

      _POS_PRODUTO := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_PRODUTO" } )
      _POS_PARNUM  := ""
      _POS_DESCRI  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_DESCRI"  } )
      _POS_UNIDADE := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_UM"      } )
      _POS_QUANTI  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_QTDVEN"  } )            
      _POS_PRCTAB  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_PRUNIT"  } )            

      If M->C5_TPFRET <> "C"
         M->C5_FRETE := 0
         M->C5_FCOR  := 0
         Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )
      Endif   

   Endif

   _Retorno := IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )

   // Zera o campo preço unitário da tabela de preço
   // Este artifício foi colocado para que o Sistema não calcule o valor de desconto
   aCols[n][_POS_PRCTAB] := 0

   // Verifica se a transportadora foi informada
   If Empty(Alltrim(_Transporte))

      If _Chamado == "PC"
         M->ADY_FRETE := 0
         M->ADY_FCOR  := 0
      Else
         M->C5_FRETE  := 0
         M->C5_FCOR   := 0
      Endif   

      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )

   Endif

   // Verifica se a transportadora é correio. Se não for, retorna
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_FRET, "
   cSql += "       ZZ4_HABI, "
   cSql += "       ZZ4_PROP, "
   cSql += "       ZZ4_CALL, "
   cSql += "       ZZ4_PEDI, "
   cSql += "       ZZ4_FREA  "
   cSql += "   FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   If T_PARAMETROS->( EOF() )
      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )      
   Endif
   
   // Verifica se a pesquisa está habilitada
   If T_PARAMETROS->ZZ4_HABI = "F"
      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )      
   Endif

   // Verifica se deve realizar a pesquisa para proposta comercial
   If T_PARAMETROS->ZZ4_PROP = "F"
      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )      
   Endif

   // Verifica se a transportadora informada é a transportadora Correios
   If Alltrim(T_PARAMETROS->ZZ4_FRET) <> Alltrim(_Transporte)
      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )      
   Endif

   If _Chamado == "PC"
      M->ADY_FRETE := 0
      M->ADY_FCOR  := 0
   Else
      M->C5_FRETE  := 0
      M->C5_FCOR   := 0
   Endif      

   If _TipoFrete <> "C"
      MsgAlert("Atenção! Indicação do tipo de frete está inconsistente. Corrija para prosseguir.")
      Return IIF( _Campo == "C", aCols[n][_POS_PRODUTO], aCols[n][_POS_QUANTI] )               
   Endif

   // Calcula o valor do frete para os produtos da proposta comercial/pedido de venda
   _vFrete := 0

   For nContar = 1 to Len(aCols)

       If aCols[nContar][Len(aHeader) + 1]
          Loop
       Endif

       __Produto    := aCols[nContar][_POS_PRODUTO]
       __Quantidade := aCols[nContar][_POS_QUANTI]

       _vFrete := _vFrete + _xSiteCorreios( __Produto, __Quantidade, _Chamado )

   Next nContar      

   If _Chamado == "PC"
      M->ADY_FRETE := _vFrete
      M->ADY_FCOR  := _vFrete
   Else
      M->C5_FRETE  := _vFrete      
      M->C5_FCOR   := _vFrete
   Endif      

   // Posiciona novamente no registro que estava no grid
   n := _Pos_Atual

Return _Retorno

// Função que dispara o envio/retorno para o site do Correio (ECT)
Static Function _xSiteCorreios(_Produto, _Quanti, _TelaTab)

   Local cSql       := ""
   Local xUrl       := ""
   Local nTimeOut   := 30
   Local aHeadOut   := {}
   Local cHeadRet   := ""
   Local sPostRet   := Nil
   Local cTime      := 0
   Local __Servico  := ""
   Local __Cliente  := IIF( _TelaTab == "PC", M->ADY_CODIGO, M->C5_CODIGO )
   Local __Loja     := IIF( _TelaTab == "PC", M->ADY_LOJA  , M->C5_LOJA   )
      
   // Pesquisa o CEP de Destino
   If Select("T_CEP") > 0
      T_CEP->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A1_CEP" 
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(__Cliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(__Loja)    + "'" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CEP", .T., .T. )

   If T_CEP->( EOF() )
      MsgAlert("Cliente inexistente.")
      Return 0
   Endif
   
   If Empty(Alltrim(T_CEP->A1_CEP))
      MsgAlert("CEP do Cliente não informado no cadastro. Corrija o cadastro para prosseguir.")
      Return 0
   Endif
         
   If Len(Alltrim(T_CEP->A1_CEP)) <> 8
      MsgAlert("CEP do Cliente inconsistente. Corrija o cadastro para prosseguir.")
      Return 0
   Endif

   // Pesquisa os parâmetros do Correio
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_HABI  ,"
   cSql += "       ZZ4_EMPR  ,"
   cSql += "       ZZ4_CSEN  ,"
   cSql += "       ZZ4_CURL  ,"
   cSql += "       ZZ4_FRET  ,"
   cSql += "       ZZ4_PROP  ,"
   cSql += "       ZZ4_CALL  ,"
   cSql += "       ZZ4_PEDI  ,"
   cSql += "       ZZ4_PESP  ,"
   cSql += "       ZZ4_ALTU  ,"
   cSql += "       ZZ4_LARG  ,"
   cSql += "       ZZ4_COMP   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return 0
   Endif

   If Alltrim(str(INT(T_PARAMETROS->ZZ4_PESP))) + ;
      Alltrim(str(INT(T_PARAMETROS->ZZ4_COMP))) + ;
      Alltrim(str(INT(T_PARAMETROS->ZZ4_ALTU))) + ;
      Alltrim(str(INT(T_PARAMETROS->ZZ4_LARG))) == "0000"
      MsgAlert("Atenção! Parametrização de Correios inexistente. Entre em contato com o Administrador para verificação!")
      Return 0
   Endif

   // Seleciona o tipo de serviço
   If _TelaTab == "PC"
      __Servico = M->ADY_TSRV
   Else
      __Servico = M->C5_TSRV      
   Endif

   // Pesquisa as dimensões e peso do produto passado no parâmetro
   If Select("T_PRODUTO") > 0
      T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_PESC,"
   cSql += "       B1_COMP,"
   cSql += "       B1_ALTU,"
   cSql += "       B1_LARG "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD     = '" + Alltrim(_Produto) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )
   
   If T_PRODUTO->( EOF() )
      _Peso := ""
      _Comp := ""
      _Altu := ""
      _Larg := ""
   Else
      _Peso := Alltrim(str((T_PRODUTO->B1_PESC * _Quanti),6,3))
      _Comp := Alltrim(str(T_PRODUTO->B1_COMP))
      _Altu := Alltrim(str(T_PRODUTO->B1_ALTU))
      _Larg := Alltrim(str(T_PRODUTO->B1_LARG))
   Endif

   // Consiste os parâmetros. Se não houver informação pelo cadastro de produtos, captura pelos parâmetros Auutomatech
   IF Alltrim(_Peso) == "0.000"
      _Peso := Alltrim(str((T_PARAMETROS->ZZ4_PESP * _Quanti),6,3))
   Endif
      
   IF Alltrim(_Comp) == "0"
      _Comp := Alltrim(str(INT(T_PARAMETROS->ZZ4_COMP)))
   Endif   

   IF Alltrim(_Altu) == "0"
      _Altu := Alltrim(str(INT(T_PARAMETROS->ZZ4_ALTU)))
   Endif

   IF Alltrim(_Larg) == "0"
      _Larg := Alltrim(str(INT(T_PARAMETROS->ZZ4_LARG)))
   Endif

   // Verifica se não existem nenhum parâmetro
   If Alltrim(_Peso) + Alltrim(_Comp) + Alltrim(_Altu) + Alltrim(_Larg) == "0000"
      MsgAlert("Atenção! Informação de Peso, Altura, Comprimento e Largura dos produtos inesistente. Verifique cadastro de produtos ou parâmetros Automatech.")
      Return 0
   Endif

   // Envia solicitação ao Correio
   xUrl := Alltrim(T_PARAMETROS->ZZ4_CURL) + ; 
           "nCdEmpresa="          + IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_EMPR)), "", Alltrim(T_PARAMETROS->ZZ4_EMPR)) + "&" + ;
           "sDsSenha="            + IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_CSEN)), "", Alltrim(T_PARAMETROS->ZZ4_CSEN)) + "&" + ;
           "sCepOrigem="          + Alltrim(SM0->M0_CEPENT)         + "&" + ;
           "sCepDestino="         + Alltrim(T_CEP->A1_CEP)          + "&" + ;
           "nVlPeso="             + _Peso                           + "&" + ;
           "nCdFormato="          + Alltrim(Str(1))                 + "&" + ;
           "nVlComprimento="      + _Comp                           + "&" + ;
           "nVlAltura="           + _Altu                           + "&" + ;
           "nVlLargura="          + _Larg                           + "&" + ;
           "sCdMaoPropria="       + Alltrim("n")                    + "&" + ;
           "nVlValorDeclarado="   + Alltrim(Str(0))                 + "&" + ;
           "sCdAvisoRecebimento=" + Alltrim("n")                    + "&" + ;
           "nCdServico="          + Alltrim(__Servico)              + "&" + ;
           "nVlDiametro="         + Alltrim(Str(0))                 + "&" + ;
           "StrRetorno=xml"

   // Agente do Browser
   //aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')')
   
   aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Windows; U; MSIE 10.6; WIndows NT 9.0; pt-BR)')

   //aadd(aHeadOut, 'User-Agent: Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0')

                
   // Envia a requisição ao SERASA
   sPostRet := HttpSPost(xUrl, "", "", "", "", "", nTimeOut, aHeadOut, @cHeadRet)

   IF !Empty(AllTrim(sPostRet))
      xFrete = VAL(STRTRAN(U_P_CORTA(SUBSTR(SPOSTRET,88 + 7,10), "<",1),",",".")) 
   Else
      MsgAlert("Erro no envio da requisição. Tente novamente.")
      xFrete := 0
   ENDIF

Return xFrete