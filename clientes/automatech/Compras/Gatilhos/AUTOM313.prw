#INCLUDE "PROTHEUS.CH"

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM313.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                     *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 21/09/2015                                                           *
// Objetivo..: Programa que carrega a coluna C7_TCUS do pedido de compra.           *
//             Este programa alimenta o campo virtual C7_TCUS com a seguinte regra: *
//             C7_TOTAL + C7_VALIPI + C7_ICMSRET                                    *
//             Também é disparado em gatilhos nos campos do pedido de compra.       *
//***********************************************************************************

User Function AUTOM313(__Campo)

   Local nCampo := 0

   U_AUTOM628("AUTOM313")

   // Gaurda o conteúdo do campo para retorno da função
   nCampo := __Campo
   
   // Captura o posicionamento dos campos no grid de produtos
   nPosUnitario := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRECO"})    
   nPosTotal    := aScan(aHeader,{|x| AllTrim(x[2])=="C7_TOTAL"})    
   nPosValIPI   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_VALIPI"})    
   nPosIcmsRet  := aScan(aHeader,{|x| AllTrim(x[2])=="C7_ICMSRET"})    
   nPosCustoUni := aScan(aHeader,{|x| AllTrim(x[2])=="C7_ZUNIT"})    
   nPosCustoTot := aScan(aHeader,{|x| AllTrim(x[2])=="C7_ZCUSTO"})    

   // aCols[n,11] = Valor do Custo Total
   // aCols[n,10] = Valor Total do Produto (Quantidade * Preço Unitário)
   // aCols[n,29] = Valor do IPI
   // aCols[n,40] = Valor do ICMS Retido

// aCols[n,11] := aCols[n,09] + aCols[n,30] + aCols[n,41]
// aCols[n,13] := aCols[n,10] + aCols[n,30] + aCols[n,41]

   aCols[n,nPosCustoUni] := aCols[n,nPosUnitario] + aCols[n,nPosValIPI] + aCols[n,nPosIcmsRet]
   aCols[n,nPosCustoTot] := aCols[n,nPosTotal]    + aCols[n,nPosValIPI] + aCols[n,nPosIcmsRet]

Return nCampo