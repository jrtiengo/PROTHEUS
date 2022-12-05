#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//*******************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                        *
// ---------------------------------------------------------------------------------------------------------------------------- *
// Referencia: AUTOM523.PRW                                                                                                     *
// Parâmetros: Nenhum                                                                                                           *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                  *
// ---------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                          *
// Data......: 03/04/2017                                                                                                       *
// Objetivo..: Programa que abre janela no pedido de compra sobre o campo quantidade do produto quando este for do grupo papeis *
// Parâmetros: <kProduto>  - Código do Produto                                                                                  *
//             <Descricao> - Descrição do Produto                                                                               *
//             <kLargura>  - Largura da Bobina                                                                                  *
//             <Metragem>  - Metragem da Bobina                                                                                 *
//             <kBobinas>  - Quantidade de Bobinas                                                                              *
// Retorno...: Quantidade Calculada                                                                                             *
//*******************************************************************************************************************************

User Function AUTOM553(kProduto, kDescricao, kLargura, kMetragem, kBobinas, kQuantidade)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   
   Local oMemo1
   Local oMemo2

   Private xProduto    := kProduto
   Private xDescricao  := kDescricao
   Private xLargura    := kLargura
   Private xMetragem   := kMetragem
   Private xBobinas    := kBobinas
   Private xQuantidade := kQuantidade

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   U_AUTOM628("AUTOM553")
   
   nPosLargura  := aScan( aHeader, { |x| x[2] == 'C7_LARG   ' } )
   nPosMetragem := aScan( aHeader, { |x| x[2] == 'C7_METR   ' } )
   nPosQBobinas := aScan( aHeader, { |x| x[2] == 'C7_QBOB   ' } )   
   nPosQuantida := aScan( aHeader, { |x| x[2] == 'C7_QUANT  ' } )   

   Private oDlg
     
   // ####################################
   // Se produto não informado, retorna ##
   // ####################################
   If Empty(Alltrim(kProduto))
      Return(xQuantidade)
   Endif
      
   // ####################################################################
   // Pesquisa o grupo do produto. Se <> de grupo de papel, não calcula ##
   // ####################################################################
   If Posicione("SB1", 1, xFilial("SB1") + xProduto, "B1_GRUPO") == "0204"
   Else
      Return(xQuantidade)
   Endif

   DEFINE MSDIALOG oDlg TITLE "Quantidade de Bobinas" FROM C(178),C(181) TO C(432),C(570) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(187),C(001) PIXEL OF oDlg
   @ C(106),C(002) GET oMemo2 Var cMemo2 MEMO Size C(187),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Produto"               Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Descrição do Produto"  Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Largura Bobina"        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(056) Say "Metragem"              Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(104) Say "Qtd Bobinas"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(154) Say "Qtd Total"             Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(144) Say "=="                    Size C(007),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(093),C(046) Say "X"                     Size C(004),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(093),C(096) Say "X"                     Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) MsGet oGet1 Var xProduto    Size C(057),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(067),C(005) MsGet oGet2 Var xDescricao  Size C(184),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(091),C(005) MsGet oGet3 Var xLargura    Size C(035),C(009) COLOR CLR_BLACK Picture "@E 99999"      PIXEL OF oDlg VALID(CalBobinas() )
   @ C(091),C(056) MsGet oGet4 Var xMetragem   Size C(035),C(009) COLOR CLR_BLACK Picture "@E 99,999.999" PIXEL OF oDlg VALID(CalBobinas() )
   @ C(091),C(104) MsGet oGet5 Var xBobinas    Size C(035),C(009) COLOR CLR_BLACK Picture "@E 99999"      PIXEL OF oDlg VALID(CalBobinas() )
   @ C(091),C(154) MsGet oGet6 Var xQuantidade Size C(035),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba

   @ C(111),C(097) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( FECHAJANB() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(xQuantidade)

// ########################################################################
// Função que calcula a quantidade pela informação dos dados das bobinas ##
// ########################################################################
Static Function CalBobinas()

   xQuantidade := ((xLargura * xMetragem) * xBobinas)
   
Return(.T.)   

// #########################################################################
// Função que fecha a janela de digitação da quantidade de produtos papel ##
// #########################################################################
Static Function FechaJanb()
                   
   aCols[n,nPosLargura]  := xLargura
   aCols[n,nPosMetragem] := xMetragem
   aCols[n,nPosQBobinas] := xBobinas
   aCols[n,nPosQuantida] := xQuantidade

   M->C7_QUANT := xQuantidade

   oDlg:End() 
   
Return(xQuantidade)