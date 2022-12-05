#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM237.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/05/2013                                                          *
// Objetivo..: Programa que totaliza os valores do Atendimento Call Center         *
//**********************************************************************************

User Function AUTOM237()

   Local nContar      := 0
   
   Local _pVlrItem    := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "UB_VRUNIT"  } )                      
   Local _pDesconto   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "UB_VALDESC" } )                      
   Local _pAcrescimo  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "UB_VALACRE" } )                         

   Local nMercadoria  := 0
   Local nAcrescimos  := 0
   Local nDescontos   := 0

   Return(.T.)
   
   For nContar = 1 to Len( aCols )
       nMercadoria  += Iif( !aCols[ nContar, Len( aHeader ) + 1 ], aCols[nContar,_pVlrItem], 0 )
       nAcrescimos  += Iif( !aCols[ nContar, Len( aHeader ) + 1 ], aCols[nContar,_pAcrescimo], 0 )
       nDescontos   += Iif( !aCols[ nContar, Len( aHeader ) + 1 ], aCols[nContar,_pDesconto], 0 )
   Next nContar   

   aValores[1] := nMercadoria  && - Total das Mercadorias
   aValores[2] := nDescontos   && - Total dos Descontos
   aValores[3] := nAcrescimos  && - Total dos Acréscimos
// aValores[4] :=              && - Total do Frete
// aValores[5] :=              && - Total das Despesas

   // Total do Pedido
   aValores[6] := aValores[1] - aValores[2] + aValores[3] + aValores[4] + aValores[5]

// aValores[7] :=              && - Total SUFRAMA

   aObj[1]:Refresh()
   aObj[2]:Refresh()
   aObj[3]:Refresh()
   aObj[4]:Refresh()
   aObj[5]:Refresh()
   aObj[6]:Refresh()
   aObj[7]:Refresh()

//   Tk273FRefresh()      // Executa o refresh nos objetos do array

//   Tk273Refresh(.T.)    // Executa o Refresh do Folder

//   Tk273TlvImp()        // Atualiza o folder do rodape com REFRESH

Return(.T.)