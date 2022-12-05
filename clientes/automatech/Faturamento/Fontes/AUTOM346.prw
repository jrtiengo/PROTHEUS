#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM346.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/05/2016                                                          *
// Objetivo..: Programa que calcula a planilha financeira utilizando o cálculo do  *
//             padrão da TOTVS para a Proposta Comercial.                          *
// Parâmetros: _Filial   = Filial da proposta comercial                            *
//             _Proposta = Proposta Comercial                                      *  
//             _Revisao  = Revisão da proposta a ser calculada                     *
//**********************************************************************************

User Function AUTOM346(_Filial, _Proposta, _Revisao)

   Local cSql           := ""
   Local kFilial        := _Filial
   Local kProposta      := _Proposta
   Local nContar        := 0
   Local xTotalProposta := 0
   Local nTaxaD         := 0
   Local nFreteProposta := 0
   Local nTProduto      := 0
   Local nContar        := 0
     
   Local aCabecalho     := {}
   Local aProdutos      := {}

   U_AUTOM628("AUTOM346")

   // Posiciona o Cabeçalho da Proposta Comercial 
   dbSelectArea("ADY")
   dbSetOrder(1)
   dbSeek( kFilial + kProposta )

   // Guarda o Valor do Frete para realizar a proporcionalidade do frete sobre os produtos
   nFreteProposta := ADY->ADY_FRETE
      
   aAdd( aCabecalho, { ADY->ADY_FILIAL,; && - 01
                       ADY->ADY_PROPOS,; && - 02
                       ADY->ADY_OPORTU,; && - 03
                       ADY->ADY_REVISA,; && - 04
                       ADY->ADY_ENTIDA,; && - 05
                       ADY->ADY_CODIGO,; && - 06
                       ADY->ADY_LOJA  ,; && - 07
                       ADY->ADY_TABELA,; && - 08
                       ADY->ADY_ORCAME,; && - 09
                       ADY->ADY_STATUS,; && - 10
                       ADY->ADY_DATA  ,; && - 11
                       ADY->ADY_VAL   ,; && - 12
                       ADY->ADY_OBSP  ,; && - 13
                       ADY->ADY_OBSI  ,; && - 14
                       ADY->ADY_TPFRET,; && - 15
                       ADY->ADY_TRANSP,; && - 16
                       ADY->ADY_TSRV  ,; && - 17
                       ADY->ADY_FRETE ,; && - 18
                       ADY->ADY_PARAQ ,; && - 19
                       ADY->ADY_ENTREG,; && - 20
                       ADY->ADY_OC    ,; && - 21
                       ADY->ADY_FCOR  ,; && - 22
                       ADY->ADY_FORMA ,; && - 23
                       ADY->ADY_ADM   ,; && - 24
                       ADY->ADY_PREVIS,; && - 25
                       ADY->ADY_CLIENT,; && - 26
                       ADY->ADY_LOJENT,; && - 27
                       ADY->ADY_VEND  ,; && - 28
                       ADY->ADY_PROCES,; && - 29
                       ADY->ADY_TPCONT,; && - 30
                       ADY->ADY_VISTEC,; && - 31
                       ADY->ADY_CODVIS,; && - 32
                       ADY->ADY_SITVIS,; && - 33
                       ADY->ADY_CONDPG,; && - 34
                       ADY->ADY_TES   ,; && - 35
                       ADY->ADY_DESCON,; && - 36
                       ADY->ADY_TPPROD,; && - 37
                       ADY->ADY_LOCAL ,; && - 38
                       ADY->ADY_DTREVI,; && - 39
                       ADY->ADY_QEXAT ,; && - 40
                       ADY->ADY_ZIDF  }) && - 41

   // Carrega os produtos da proposta comercial
   If (Select( "T_PRODUTOS" ) != 0 )
      T_PRODUTOS->( DbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ADZ.ADZ_FILIAL,"
   cSql += "       ADZ.ADZ_ITEM  ,"
   cSql += "       ADZ.ADZ_PRODUT,"
   cSql += "       ADZ.ADZ_DESCRI,"
   cSql += "       ADZ.ADZ_UM    ,"
   cSql += "       ADZ.ADZ_LACRE ,"
   cSql += "       ADZ.ADZ_MOEDA ,"
   cSql += "       ADZ.ADZ_CONDPG,"
   cSql += "       ADZ.ADZ_QTDVEN,"
   cSql += "       ADZ.ADZ_PRCVEN,"
   cSql += "       ADZ.ADZ_PRCTAB,"
   cSql += "       ADZ.ADZ_DESCON,"
   cSql += "       ADZ.ADZ_VALDES,"
   cSql += "       ADZ.ADZ_PMS   ,"
   cSql += "       ADZ.ADZ_DT1VEN,"
   cSql += "       ADZ.ADZ_ITEMOR,"
   cSql += "       ADZ.ADZ_ORCAME,"
   cSql += "       ADZ.ADZ_PROPOS,"
   cSql += "       ADZ.ADZ_FOLDER,"
   cSql += "       ADZ.ADZ_ITPAI ,"
   cSql += "       ADZ.ADZ_TES   ,"
   cSql += "       ADZ.ADZ_COMIS1,"
   cSql += "       ADZ.ADZ_COMIS2,"
   cSql += "       ADZ.ADZ_QTGMRG,"
   cSql += "       ADZ.ADZ_MARGEM,"
   cSql += "       ADZ.ADZ_ORDC  ,"
   cSql += "       ADZ.ADZ_ORDA  ," 
   cSql += "       ADZ.ADZ_DEVO  ,"
   cSql += "       ADZ.ADZ_TPPROD,"
   cSql += "       ADZ.ADZ_PRDALO,"
   cSql += "       ADZ.ADZ_LOCAL ,"
   cSql += "       ADZ.ADZ_REVISA,"
   cSql += "       ADZ.ADZ_DTENTR,"
   cSql += "       ADZ.ADZ_ORDS   "
   cSql += "  FROM " + RetSqlName("ADZ") + " ADZ "
   cSql += " WHERE ADZ.ADZ_FILIAL = '" + Alltrim(kFilial)   + "'"
   cSql += "   AND ADZ.ADZ_PROPOS = '" + Alltrim(kProposta) + "'"
   cSql += "   AND ADZ.ADZ_REVISA = '" + Alltrim(_Revisao)  + "'"
   cSql += "   AND ADZ.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)
          
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      aAdd( aProdutos, {T_PRODUTOS->ADZ_FILIAL      ,; && - 01
                        T_PRODUTOS->ADZ_ITEM        ,; && - 02
                        T_PRODUTOS->ADZ_PRODUT      ,; && - 03
                        T_PRODUTOS->ADZ_DESCRI      ,; && - 04
                        T_PRODUTOS->ADZ_UM          ,; && - 05
                        T_PRODUTOS->ADZ_LACRE       ,; && - 06
                        T_PRODUTOS->ADZ_CONDPG      ,; && - 07
                        T_PRODUTOS->ADZ_QTDVEN      ,; && - 08
                        T_PRODUTOS->ADZ_DESCON      ,; && - 09
                        T_PRODUTOS->ADZ_MOEDA       ,; && - 10
                        T_PRODUTOS->ADZ_MOEDA       ,; && - 11
                        T_PRODUTOS->ADZ_PRCVEN      ,; && - 12
                        T_PRODUTOS->ADZ_PRCTAB      ,; && - 13
                        T_PRODUTOS->ADZ_VALDES      ,; && - 14
                        T_PRODUTOS->ADZ_PMS         ,; && - 15
                        CTOD(T_PRODUTOS->ADZ_DT1VEN),; && - 16
                        T_PRODUTOS->ADZ_ITEMOR      ,; && - 17
                        T_PRODUTOS->ADZ_ORCAME      ,; && - 18
                        T_PRODUTOS->ADZ_PROPOS      ,; && - 19
                        T_PRODUTOS->ADZ_FOLDER      ,; && - 20
                        T_PRODUTOS->ADZ_ITPAI       ,; && - 21
                        T_PRODUTOS->ADZ_TES         ,; && - 22
                        T_PRODUTOS->ADZ_COMIS1      ,; && - 23
                        T_PRODUTOS->ADZ_COMIS2      ,; && - 24
                        T_PRODUTOS->ADZ_QTGMRG      ,; && - 25
                        T_PRODUTOS->ADZ_MARGEM      ,; && - 26
                        T_PRODUTOS->ADZ_ORDC        ,; && - 27
                        T_PRODUTOS->ADZ_ORDA        ,; && - 28
                        CTOD(T_PRODUTOS->ADZ_DEVO)  ,; && - 29
                        T_PRODUTOS->ADZ_TPPROD      ,; && - 30
                        T_PRODUTOS->ADZ_PRDALO      ,; && - 31
                        T_PRODUTOS->ADZ_LOCAL       ,; && - 32
                        T_PRODUTOS->ADZ_REVISA      ,; && - 33
                        CTOD(T_PRODUTOS->ADZ_DTENTR),; && - 34
                        T_PRODUTOS->ADZ_ORDS        ,; && - 35
                        0                           ,; && - 36
                        0                           ,; && - 37
                        0                           ,; && - 38
                        0                           ,; && - 39
                        0                           ,; && - 40
                        0                           ,; && - 41
                        0                           ,; && - 42
                        0                           }) && - 43                                                                                                                        

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   // Pesquisa o valor total da proposta para calcular o valor proporcionalizado do frete entre os produtos
   // Regra para proporcionalizar o valor do frete
   // Se a proposta comercial for toda ela de mesma moeda, proposcionaliza em todos os produtos
   // Se a proposta comercial tiver duas moedas, proporcionaliza somente para produtos da moeda do primeiro produto
   If nFreteProposta == 0
   Else

      // Verifica quantas moedas tem a proposta comecial
      If (Select( "T_MOEDA" ) != 0 )
         T_MOEDA->( DbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ADZ_MOEDA"
      cSql += "  FROM " + RetSqlName("ADZ")
      cSql += " WHERE ADZ_FILIAL = '" + Alltrim(kFilial)   + "'"
      cSql += "   AND ADZ_PROPOS = '" + Alltrim(kProposta) + "'"
      cSql += "   AND ADZ_REVISA = '" + Alltrim(_Revisao)  + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MOEDA",.T.,.T.)

      cSigla := T_MOEDA->ADZ_MOEDA

      // Captura o valor total dos produtos conforme a moeda selecionada
      If (Select( "T_TOTALPROPOSTA" ) != 0 )
         T_TOTALPROPOSTA->( DbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT SUM((ADZ_QTDVEN * ADZ_PRCVEN)) AS TOTAL_PROPOSTA"
      cSql += "  FROM " + RetSqlName("ADZ")
      cSql += " WHERE ADZ_FILIAL = '" + Alltrim(kFilial)   + "'"
      cSql += "   AND ADZ_PROPOS = '" + Alltrim(kProposta) + "'"
      cSql += "   AND ADZ_REVISA = '" + Alltrim(_Revisao)  + "'"
      cSql += "   AND ADZ_MOEDA  = '" + Alltrim(cSigla)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TOTALPROPOSTA",.T.,.T.)
      
      // Proporcionaliza o valor do frete para o produto lido   
      For nContar = 1 to Len(aProdutos)

          If aProdutos[nContar,10] == cSigla
             nPercentual := Round((((aProdutos[nContar,08] * aProdutos[nContar,12]) / T_TOTALPROPOSTA->TOTAL_PROPOSTA) * 100),2)
             aProdutos[nContar,36] := Round(((nFreteProposta * nPercentual) / 100),2)       
          Else
             aProdutos[nContar,36] := 0
          Endif
            
      Next nContar
            
   Endif

   // Pesquisa o tipo de cliente
   xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + aCabecalho[01,06] + aCabecalho[01,07],"A1_TIPO")
      
   // Calculo ST e Outros Impostos                      
   MaFisIni(aCabecalho[01,06], aCabecalho[01,07], "C", "N", xTipoCli, MaFisRelImp("MTR700",{"ADY","ADZ"}),,,"SB1","MTR700")

   // Calcula os Impostos
   nContar := 0
   
   For nContar = 1 to Len(aprodutos)

       nTProduto := 0
       nTProduto := (aProdutos[nContar,08] * aProdutos[nContar,12]) + aProdutos[nContar,36] - aProdutos[nContar,14]

       // Calcula os Impostos
       MaFisAdd(aProdutos[nContar,03] ,; // 01 - Código do Produto (Obrigatório)
                aProdutos[nContar,22] ,; // 02 - Código do TES (Obrigatório)
                aProdutos[nContar,08] ,; // 03 - Quantidade de Venda do Produto (Obrigatório)
                aProdutos[nContar,12] ,; // 04 - Preço Unitário de Venda do Produto (Obrigatório)
                aProdutos[nContar,14] ,; // 05 - Valor do Desconto (Opcional)
                ""                    ,; // 06 - Nº da NF Original (Devolução/Beneficiamento)
                ""                    ,; // 07 - Série da NF Original (Devolução/Beneficiamento)
                0                     ,; // 08 - RecNo da NF Original do arq SD1/SD2
                0                     ,; // 09 - Valor do Frete do Item ( Opcional )
                0                     ,; // 10 - Valor da Despesa do item ( Opcional )
                0                     ,; // 11 - Valor do Seguro do item ( Opcional )
                0                     ,; // 12 - Valor do Frete Autonomo ( Opcional )
                nTProduto             ,; // 13 - Valor da Mercadoria ( Obrigatorio )
                0                     ,; // 14 - Valor da Embalagem ( Opiconal )
                0                     ,; // 15 - RecNo do SB1
                0)                       // 16 - RecNo do SF4

       _nAliqIcm := MaFisRet(nContar,"IT_ALIQICM")
       _nValIcm  := MaFisRet(nContar,"IT_VALICM" )
       _nBaseIcm := MaFisRet(nContar,"IT_BASEICM")
       _nValIpi  := MaFisRet(nContar,"IT_VALIPI" )
       _nBaseIpi := MaFisRet(nContar,"IT_BASEICM")
       _nValMerc := MaFisRet(nContar,"IT_VALMERC")
       _nValSol  := MaFisRet(nContar,"IT_VALSOL" )

       aProdutos[nContar,37] := _nAliqIcm
       aProdutos[nContar,38] := _nValIcm
       aProdutos[nContar,39] := _nBaseIcm
       aProdutos[nContar,40] := _nValIpi
       aProdutos[nContar,41] := _nBaseIpi
       aProdutos[nContar,42] := _nValMerc
       aProdutos[nContar,43] := _nValSol

   Next nContar

   MaFisEnd()
  
Return aProdutos

// Função que pesquisa a taxa do dolar para o item/produto enviados para a função
Static Function Busca_Taxa_Dolar(_TFilial, _TProposta, _TItem, _TProduto)

   Local nValor_Taxa := 0

   If (Select( "T_PEDIDO" ) != 0 )
      T_PEDIDO->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SCK.CK_FILIAL ,"
   cSql += "       SCK.CK_PROPOST,"
   cSql += "       SCK.CK_NUMPV  ,"
   cSql += "       SCK.CK_ITEM   ,"
   cSql += "       SCK.CK_ITEMPRO,"
   cSql += "       SCK.CK_PRODUTO,"
   cSql += "      (SELECT C6_NOTA "
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  " 
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS NOTA,  "
   cSql += "      (SELECT C6_SERIE "
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  "
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS SERIE, "
   cSql += "      (SELECT C6_DATFAT"
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  "
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS DATA_FATURAMENTO"
   cSql += "   FROM " + RetSqlName("SCK") + " SCK "
   cSql += "  WHERE SCK.CK_FILIAL  = '" + Alltrim(_TFilial)   + "'"
   cSql += "    AND SCK.CK_PROPOST = '" + Alltrim(_TProposta) + "'"
   cSql += "    AND SCK.CK_ITEMPRO = '" + Alltrim(_TItem)     + "'"
   cSql += "    AND SCK.CK_PRODUTO = '" + Alltrim(_TProduto)  + "'"
   cSql += "    AND SCK.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PEDIDO",.T.,.T.)
   
   // Se não encontrar registro na tabela SCK, grava taxa do dolar do dia
   IF T_PEDIDO->( EOF() )
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Endif

   // Encontrou registro na tabela SCK porém ainda não existe pedido de venda vinculado a proposta comercial
   If Empty(Alltrim(T_PEDIDO->CK_NUMPV))
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Endif
       
   // Verifica se o pedido de venda para o item/produto já está faturado.
   // Se está faturado, pesquisa a taxa do dolar da data do faturamento senão, data atual
   If Empty(Alltrim(T_PEDIDO->NOTA))
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Else
      nValor_Taxa := Posicione( "SM2", 1, T_PEDIDO->DATA_FATURAMENTO, "M2_MOEDA2" )
      Return(nValor_Taxa)
   Endif
       
Return(nValorTaxa)




































/*




User Function AUTOM346(_Filial, _Proposta)

   Local cSql           := ""
   Local kFilial        := _Filial
   Local kProposta      := _Proposta
   Local nContar        := 0
   Local xTotalProposta := 0
   Local aProdutos      := {}
   Local nTaxaD         := 0
   Local nFreteProposta := 0
   Local nTProduto      := 0
   Local nContar        := 0
     
   // Posiciona o Cabeçalho da Proposta Comercial 
   dbSelectArea("ADY")
   dbSetOrder(1)
   dbSeek( kFilial + kProposta )

   dbSelectArea("ZTL")
   dbSetOrder(1)
   If dbSeek( kFilial + kProposta )
      aArea := GetArea()
      dbSelectArea("ZTL")
      RecLock("ZTL",.F.)
   Else
      aArea := GetArea()
      dbSelectArea("ZTL")
      RecLock("ZTL",.T.)
   Endif      

   // Guarda o Valor do Frete para realizar a proporcionalidade do frete sobre os produtos
   nFreteProposta := ADY->ADY_FRETE
      
   ZTL_FILIAL  := ADY->ADY_FILIAL
   ZTL_PROPOS  := ADY->ADY_PROPOS
   ZTL_OPORTU  := ADY->ADY_OPORTU
   ZTL_REVISA  := ADY->ADY_REVISA
   ZTL_ENTIDA  := ADY->ADY_ENTIDA
   ZTL_CODIGO  := ADY->ADY_CODIGO
   ZTL_LOJA    := ADY->ADY_LOJA
   ZTL_TABELA  := ADY->ADY_TABELA
   ZTL_ORCAME  := ADY->ADY_ORCAME
   ZTL_STATUS  := ADY->ADY_STATUS
   ZTL_DATA    := ADY->ADY_DATA
   ZTL_VAL     := ADY->ADY_VAL
   ZTL_OBSP    := ADY->ADY_OBSP
   ZTL_OBSI    := ADY->ADY_OBSI
   ZTL_TPFRET  := ADY->ADY_TPFRET
   ZTL_TRANSP  := ADY->ADY_TRANSP
   ZTL_TSRV    := ADY->ADY_TSRV
   ZTL_FRETE   := ADY->ADY_FRETE
   ZTL_PARAQ   := ADY->ADY_PARAQ
   ZTL_ENTREG  := ADY->ADY_ENTREG
   ZTL_OC      := ADY->ADY_OC
   ZTL_FCOR    := ADY->ADY_FCOR
   ZTL_FORMA   := ADY->ADY_FORMA
   ZTL_ADM     := ADY->ADY_ADM
   ZTL_PREVIS  := ADY->ADY_PREVIS
   ZTL_CLIENT  := ADY->ADY_CLIENT
   ZTL_LOJAENT := ADY->ADY_LOJENT
   ZTL_VEND    := ADY->ADY_VEND
   ZTL_PROCES  := ADY->ADY_PROCES
   ZTL_TPCONT  := ADY->ADY_TPCONT
   ZTL_VISTEC  := ADY->ADY_VISTEC
   ZTL_CODVIS  := ADY->ADY_CODVIS
   ZTL_SITVIS  := ADY->ADY_SITVIS
   ZTL_CONDPG  := ADY->ADY_CONDPG
   ZTL_TES     := ADY->ADY_TES
   ZTL_DESCON  := ADY->ADY_DESCON
   ZTL_TPPROD  := ADY->ADY_TPPROD
   ZTL_LOCAL   := ADY->ADY_LOCAL
   ZTL_DTREVI  := ADY->ADY_DTREVI
   ZTL_QEXAT   := ADY->ADY_QEXAT
   ZTL_ZIDF    := ADY->ADY_ZIDF

   MsUnLock()
   aArea := GetArea()

   // Carrega os produtos da proposta comercial
   If (Select( "T_PRODUTOS" ) != 0 )
      T_PRODUTOS->( DbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ADZ.ADZ_FILIAL,"
   cSql += "       ADZ.ADZ_ITEM  ,"
   cSql += "       ADZ.ADZ_PRODUT,"
   cSql += "       ADZ.ADZ_DESCRI,"
   cSql += "       ADZ.ADZ_UM    ,"
   cSql += "       ADZ.ADZ_LACRE ,"
   cSql += "       ADZ.ADZ_MOEDA ,"
   cSql += "       ADZ.ADZ_CONDPG,"
   cSql += "       ADZ.ADZ_QTDVEN,"
   cSql += "       ADZ.ADZ_PRCVEN,"
   cSql += "       ADZ.ADZ_PRCTAB,"
   cSql += "       ADZ.ADZ_DESCON,"
   cSql += "       ADZ.ADZ_VALDES,"
   cSql += "       ADZ.ADZ_PMS   ,"
   cSql += "       ADZ.ADZ_DT1VEN,"
   cSql += "       ADZ.ADZ_ITEMOR,"
   cSql += "       ADZ.ADZ_ORCAME,"
   cSql += "       ADZ.ADZ_PROPOS,"
   cSql += "       ADZ.ADZ_FOLDER,"
   cSql += "       ADZ.ADZ_ITPAI ,"
   cSql += "       ADZ.ADZ_TES   ,"
   cSql += "       ADZ.ADZ_COMIS1,"
   cSql += "       ADZ.ADZ_COMIS2,"
   cSql += "       ADZ.ADZ_QTGMRG,"
   cSql += "       ADZ.ADZ_MARGEM,"
   cSql += "       ADZ.ADZ_ORDC  ,"
   cSql += "       ADZ.ADZ_ORDA  ," 
   cSql += "       ADZ.ADZ_DEVO  ,"
   cSql += "       ADZ.ADZ_TPPROD,"
   cSql += "       ADZ.ADZ_PRDALO,"
   cSql += "       ADZ.ADZ_LOCAL ,"
   cSql += "       ADZ.ADZ_REVISA,"
   cSql += "       ADZ.ADZ_DTENTR,"
   cSql += "       ADZ.ADZ_ORDS   "
   cSql += "  FROM " + RetSqlName("ADZ") + " ADZ "
   cSql += " WHERE ADZ.ADZ_FILIAL = '" + Alltrim(kFilial)   + "'"
   cSql += "   AND ADZ.ADZ_PROPOS = '" + Alltrim(kProposta) + "'"
   cSql += "   AND ADZ.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)
          
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      // Se produto em moeda Dolar, conver para reais
      nTaxaD := 0
      If T_PRODUTOS->ADZ_MOEDA = "2"
         nTaxaD := Busca_Taxa_Dolar(T_PRODUTOS->ADZ_FILIAL, T_PRODUTOS->ADZ_PROPOS, T_PRODUTOS->ADZ_ITEM, T_PRODUTOS->ADZ_PRODUT)
      Endif
                  
      // Verifica se Produto já existe na tabela ZTM
      dbSelectArea("ZTM")
      dbSetOrder(1)
      If dbSeek( T_PRODUTOS->ADZ_FILIAL + T_PRODUTOS->ADZ_PROPOS + T_PRODUTOS->ADZ_ITEM )
         aArea := GetArea()
         dbSelectArea("ZTM")
         RecLock("ZTM",.F.)
      Else
         aArea := GetArea()
         dbSelectArea("ZTM")
         RecLock("ZTM",.T.)
      Endif      
   
      ZTM_FILIAL := T_PRODUTOS->ADZ_FILIAL
      ZTM_ITEM   := T_PRODUTOS->ADZ_ITEM  
      ZTM_PRODUT := T_PRODUTOS->ADZ_PRODUT
      ZTM_DESCRI := T_PRODUTOS->ADZ_DESCRI
      ZTM_UM     := T_PRODUTOS->ADZ_UM    
      ZTM_LACRE  := T_PRODUTOS->ADZ_LACRE 
      ZTM_CONDPG := T_PRODUTOS->ADZ_CONDPG
      ZTM_QTDVEN := T_PRODUTOS->ADZ_QTDVEN
      ZTM_DESCON := T_PRODUTOS->ADZ_DESCON
      ZTM_MOEDA  := T_PRODUTOS->ADZ_MOEDA
      ZTM_MORI   := T_PRODUTOS->ADZ_MOEDA
      ZTM_PRCVEN := T_PRODUTOS->ADZ_PRCVEN
      ZTM_PRCTAB := T_PRODUTOS->ADZ_PRCTAB
      ZTM_VALDES := T_PRODUTOS->ADZ_VALDES
      ZTM_PMS    := T_PRODUTOS->ADZ_PMS   
      ZTM_DT1VEN := CTOD(T_PRODUTOS->ADZ_DT1VEN)
      ZTM_ITEMOR := T_PRODUTOS->ADZ_ITEMOR
      ZTM_ORCAME := T_PRODUTOS->ADZ_ORCAME
      ZTM_PROPOS := T_PRODUTOS->ADZ_PROPOS
      ZTM_FOLDER := T_PRODUTOS->ADZ_FOLDER
      ZTM_ITPAI  := T_PRODUTOS->ADZ_ITPAI 
      ZTM_TES    := T_PRODUTOS->ADZ_TES   
      ZTM_COMIS1 := T_PRODUTOS->ADZ_COMIS1
      ZTM_COMIS2 := T_PRODUTOS->ADZ_COMIS2
      ZTM_QTGMRG := T_PRODUTOS->ADZ_QTGMRG
      ZTM_MARGEM := T_PRODUTOS->ADZ_MARGEM
      ZTM_ORDC   := T_PRODUTOS->ADZ_ORDC  
      ZTM_ORDA   := T_PRODUTOS->ADZ_ORDA   
      ZTM_DEVO   := CTOD(T_PRODUTOS->ADZ_DEVO)
      ZTM_TPPROD := T_PRODUTOS->ADZ_TPPROD
      ZTM_PRDALO := T_PRODUTOS->ADZ_PRDALO
      ZTM_LOCAL  := T_PRODUTOS->ADZ_LOCAL 
      ZTM_REVISA := T_PRODUTOS->ADZ_REVISA
      ZTM_DTENTR := CTOD(T_PRODUTOS->ADZ_DTENTR)
      ZTM_ORDS   := T_PRODUTOS->ADZ_ORDS  

      MsUnLock()
      aArea := GetArea()
      
      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   // Pesquisa o valor total da proposta para calcular o valor proporcionalizado do frete entre os produtos
   // Regra para proporcionalizar o valor do frete
   // Se a proposta comercial for toda ela de mesma moeda, proposcionaliza em todos os produtos
   // Se a proposta comercial tiver duas moedas, proporcionaliza somente para produtos da moeda do primeiro produto
   If nFreteProposta == 0
   Else

      // Verifica quantas moedas tem a proposta comecial
      If (Select( "T_MOEDA" ) != 0 )
         T_MOEDA->( DbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ADZ_MOEDA"
      cSql += "  FROM " + RetSqlName("ADZ")
      cSql += " WHERE ADZ_FILIAL = '" + Alltrim(kFilial)   + "'"
      cSql += "   AND ADZ_PROPOS = '" + Alltrim(kProposta) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MOEDA",.T.,.T.)

      cSigla := T_MOEDA->ADZ_MOEDA

      // Captura o valor total dos produtos conforme a moeda selecionada
      If (Select( "T_TOTALPROPOSTA" ) != 0 )
         T_TOTALPROPOSTA->( DbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT SUM((ZTM_QTDVEN * ZTM_PRCVEN)) AS TOTAL_PROPOSTA"
      cSql += "  FROM " + RetSqlName("ZTM")
      cSql += " WHERE ZTM_FILIAL = '" + Alltrim(kFilial)   + "'"
      cSql += "   AND ZTM_PROPOS = '" + Alltrim(kProposta) + "'"
      cSql += "   AND ZTM_MOEDA  = '" + Alltrim(cSigla)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TOTALPROPOSTA",.T.,.T.)
      

      // Pesquisa os registros que serão envolvidos no cálculo do frete
      If (Select( "T_FRETE" ) != 0 )
         T_FRETE->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := " SELECT ZTM_FILIAL,"
      cSql += "        ZTM_ITEM  ,"
      cSql += "        ZTM_PRODUT,"
      cSql += "        ZTM_PROPOS,"
      cSql += "        ZTM_QTDVEN,"
      cSql += "        ZTM_PRCVEN,"
      cSql += "        ZTM_MOEDA  "
      cSql += "  FROM " + RetSqlName("ZTM")
      cSql += " WHERE ZTM_FILIAL = '" + Alltrim(kFilial)   + "'"
      cSql += "   AND ZTM_PROPOS = '" + Alltrim(kProposta) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FRETE",.T.,.T.)

      T_FRETE->( DbGoTop() )
   
      WHILE !T_FRETE->( EOF() )
   
         // Verifica se Produto já existe na tabela ZTM
         dbSelectArea("ZTM")
         dbSetOrder(1)
         If dbSeek( T_FRETE->ZTM_FILIAL + T_FRETE->ZTM_PROPOS + T_FRETE->ZTM_ITEM )

            If T_FRETE->ZTM_MOEDA == cSigla

               RecLock("ZTM",.F.)

               // Proporcionaliza o valor do frete para o produto lido
               nPercentual := Round((((T_FRETE->ZTM_QTDVEN * T_FRETE->ZTM_PRCVEN) / T_TOTALPROPOSTA->TOTAL_PROPOSTA) * 100),2)
               ZTM_PFRE    := Round(((nFreteProposta * nPercentual) / 100),2)
       
               MsUnLock()
   
            Else
               RecLock("ZTM",.F.)
               ZTM_PFRE := 0
               MsUnLock()
            Endif
            
         Endif
         
         T_FRETE->( DbSkip() )
         
      ENDDO
            
   Endif

   // Posiciona o Cabeçalho da Proposta Comercial para carga do cabeçalho da proposta comercial
   dbSelectArea("ZTL")
   dbSetOrder(1)
   dbSeek( kFilial + kProposta )

   // Pesquisa o tipo de cliente
   xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + ZTL->ZTL_CODIGO + ZTL->ZTL_LOJA,"A1_TIPO")
      
   // Calculo ST e Outros Impostos                      
   MaFisIni(ZTL->ZTL_CODIGO, ZTL->ZTL_LOJA, "C", "N", xTipoCli, MaFisRelImp("MTR700",{"ZTL","ZTM"}),,,"SB1","MTR700")

   // Pesquisa dados da proposta comercial para cálculo do difal por produtos
   If (Select( "T_PRODUTOS" ) != 0 )
      T_PRODUTOS->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTM.ZTM_PROPOS,"
   cSql += "       ZTM.ZTM_FILIAL,"
   cSql += "       ZTM.ZTM_ITEM  ,"
   cSql += "       ZTM.ZTM_PRODUT,"
   cSql += "       ZTM.ZTM_TES   ," 
   cSql += "       ZTM.ZTM_MOEDA ,"
   cSql	+= "       ZTM.ZTM_QTDVEN,"
   cSql	+= "       ZTM.ZTM_PRCVEN,"
   cSql += "	   ZTM.ZTM_VALDES,"
   cSql += "       ZTM.ZTM_PFRE  ,"
   cSql += "       ZTL.ZTL_CODIGO,"
   cSql += "       ZTL.ZTL_LOJA  ,"
   cSql += "       ZTL.ZTL_FRETE ,"
   cSql += "       SA1.A1_TIPO    "
   cSql += "  FROM " + RetSqlName("ZTM") + " ZTM, "
   cSql += "       " + RetSqlName("ZTL") + " ZTL, "
   cSql += "	   " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE ZTM.ZTM_FILIAL = '" + Alltrim(kFilial)   + "'"
   cSql += "   AND ZTM.ZTM_PROPOS = '" + Alltrim(kProposta) + "'"
   cSql += "   AND ZTM.D_E_L_E_T_ = ''"
   cSql += "   AND ZTL.ZTL_FILIAL = ZTM.ZTM_FILIAL"
   cSql += "   AND ZTL.ZTL_PROPOS = ZTM.ZTM_PROPOS"
   cSql += "   AND ZTL.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = ZTL.ZTL_CODIGO"
   cSql += "   AND SA1.A1_LOJA    = ZTL.ZTL_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)

   T_PRODUTOS->( DbGoTop() )
 
   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      nTProduto := 0
      nTProduto := (T_PRODUTOS->ZTM_QTDVEN * T_PRODUTOS->ZTM_PRCVEN) + T_PRODUTOS->ZTM_PFRE - T_PRODUTOS->ZTM_VALDES               

      // Calcula os Impostos
      MaFisAdd(T_PRODUTOS->ZTM_PRODUT,; // 01 - Código do Produto (Obrigatório)
               T_PRODUTOS->ZTM_TES   ,; // 02 - Código do TES (Obrigatório)
               T_PRODUTOS->ZTM_QTDVEN,; // 03 - Qunatidade de Venda do Produto (Obrigatório)
               T_PRODUTOS->ZTM_PRCVEN,; // 04 - Preço Unitário de Venda do Produto (Obrigatório)
               T_PRODUTOS->ZTM_VALDES,; // 05 - Valor do Desconto (Opcional)
               ""                    ,; // 06 - Nº da NF Original (Devolução/Beneficiamento)
               ""                    ,; // 07 - Série da NF Original (Devolução/Beneficiamento)
               0                     ,; // 08 - RecNo da NF Original do arq SD1/SD2
               0                     ,; // 09 - Valor do Frete do Item ( Opcional )
               0                     ,; // 10 - Valor da Despesa do item ( Opcional )
               0                     ,; // 11 - Valor do Seguro do item ( Opcional )
               0                     ,; // 12 - Valor do Frete Autonomo ( Opcional )
               nTProduto             ,; // 13 - Valor da Mercadoria ( Obrigatorio )
               0                     ,; // 14 - Valor da Embalagem ( Opiconal )
               0                     ,; // 15 - RecNo do SB1
               0)                       // 16 - RecNo do SF4

   nContar := nContar + 1

   _nAliqIcm := MaFisRet(nContar,"IT_ALIQICM")
   _nValIcm  := MaFisRet(nContar,"IT_VALICM" )
   _nBaseIcm := MaFisRet(nContar,"IT_BASEICM")
   _nValIpi  := MaFisRet(nContar,"IT_VALIPI" )
   _nBaseIpi := MaFisRet(nContar,"IT_BASEICM")
   _nValMerc := MaFisRet(nContar,"IT_VALMERC")
   _nValSol  := MaFisRet(nContar,"IT_VALSOL" )

      MsgAlert("IT_ALIQICM: " + Str(_nAliqIcm,10,02) + chr(13) + ;
               "IT_VALICM:"   + Str(_nValIcm,10,02) + chr(13) + ;
               "IT_BASEICM:"  + Str(_nBaseIcm,10,02) + chr(13) + ;
               "IT_VALIPI:"   + Str(_nValIpi,10,02) + chr(13) + ;
               "IT_BASEICM:"  + Str(_nBaseIpi,10,02) + chr(13) + ;
               "IT_VALMERC:"  + Str(_nValMerc,10,02) + chr(13) + ;
               "IT_VALSOL:"   + Str(_nValSol,10,02) + chr(13))

      T_PRODUTOS->( DbSkip() )

   Enddo

   MaFisEnd()
  
Return(.T.)

// Função que pesquisa a taxa do dolar para o item/produto enviados para a função
Static Function Busca_Taxa_Dolar(_TFilial, _TProposta, _TItem, _TProduto)

   Local nValor_Taxa := 0

   If (Select( "T_PEDIDO" ) != 0 )
      T_PEDIDO->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SCK.CK_FILIAL ,"
   cSql += "       SCK.CK_PROPOST,"
   cSql += "       SCK.CK_NUMPV  ,"
   cSql += "       SCK.CK_ITEM   ,"
   cSql += "       SCK.CK_ITEMPRO,"
   cSql += "       SCK.CK_PRODUTO,"
   cSql += "      (SELECT C6_NOTA "
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  " 
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS NOTA,  "
   cSql += "      (SELECT C6_SERIE "
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  "
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS SERIE, "
   cSql += "      (SELECT C6_DATFAT"
   cSql += "         FROM " + RetSqlName("SC6")
   cSql += "        WHERE C6_FILIAL  = SCK.CK_FILIAL "
   cSql += "          AND C6_NUM     = SCK.CK_NUMPV  "
   cSql += "          AND C6_PRODUTO = SCK.CK_PRODUTO"
   cSql += "          AND C6_ITEM    = SCK.CK_ITEM   "
   cSql += "          AND D_E_L_E_T_ = '') AS DATA_FATURAMENTO"
   cSql += "   FROM " + RetSqlName("SCK") + " SCK "
   cSql += "  WHERE SCK.CK_FILIAL  = '" + Alltrim(_TFilial)   + "'"
   cSql += "    AND SCK.CK_PROPOST = '" + Alltrim(_TProposta) + "'"
   cSql += "    AND SCK.CK_ITEMPRO = '" + Alltrim(_TItem)     + "'"
   cSql += "    AND SCK.CK_PRODUTO = '" + Alltrim(_TProduto)  + "'"
   cSql += "    AND SCK.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PEDIDO",.T.,.T.)
   
   // Se não encontrar registro na tabela SCK, grava taxa do dolar do dia
   IF T_PEDIDO->( EOF() )
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Endif

   // Encontrou registro na tabela SCK porém ainda não existe pedido de venda vinculado a proposta comercial
   If Empty(Alltrim(T_PEDIDO->CK_NUMPV))
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Endif
       
   // Verifica se o pedido de venda para o item/produto já está faturado.
   // Se está faturado, pesquisa a taxa do dolar da data do faturamento senão, data atual
   If Empty(Alltrim(T_PEDIDO->NOTA))
      nValor_Taxa := Posicione("SM2", 1, DATE(), "M2_MOEDA2")
      Return(nValor_Taxa)
   Else
      nValor_Taxa := Posicione( "SM2", 1, T_PEDIDO->DATA_FATURAMENTO, "M2_MOEDA2" )
      Return(nValor_Taxa)
   Endif
       
Return(nValorTaxa)

*/