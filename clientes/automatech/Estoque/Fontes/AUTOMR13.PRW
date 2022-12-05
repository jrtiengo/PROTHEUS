#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR13.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/09/2011                                                          *
// Objetivo..: Impressão Etiqueta com o nº do Pedido de Venda.                     *
//             Chamado pela tela de Separação	                                   *
// Parâmetros: < cPedido > - Nº do Pedido de Venda                                 *
//             < _Volume > - Valumes do pedido                                     *
//**********************************************************************************

// Função que define a Window
User Function AUTOMR13(_Pedido, _Volume)
 
   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Variáveis Private da Função
   Private aComboBx1 := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cComboBx1 := "COM1"
   Private cCodigo    := space(6)
   Private cDescricao := space(40)
   Private cPartNum   := space(40)
   Private nGet1	  := Alltrim(Str(_Volume,5))
   Private nGet2	  := space(6)
   Private nGet3	  := space(40)
      
   // Diálogo Principal
   Private oDlg

   // Variáveis que definem a Ação do Formulário

   U_AUTOM628("AUTOMR13")

   DEFINE MSDIALOG oDlg TITLE "Impressão de Etiqueta de Produtos" FROM C(178),C(181) TO C(310),C(450) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(010),C(005) Say "Nº Pedido:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(025) say _Pedido      Size C(080),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(022),C(005) Say "Qtd Etq:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(020),C(025) MsGet oGet1 Var nGet1 Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(035),C(005) Say "Porta:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(025) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
		                        
   DEFINE SBUTTON FROM C(50),C(112) TYPE  6 ENABLE OF oDlg ACTION( AUTR012A(_Pedido, nGet1, cCombobx1)  )
   DEFINE SBUTTON FROM C(50),C(090) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Função que imprime a etiqueta
static function AUTR012A(_xPedido, nGet1, cPorta)

   Local cPorta    := cPorta
   Local nQtetq    := val(nGet1)
   Local cPedido   := _xPedido
   Local nContar   := 0
   Local nLaco     := 0
   Local _aAreaSC5 := SC5->(GetArea())//Adicionado Michel Aoki 25/09/2014
   Local _cEmissao := ""

   // Estrutura do comando
   // 191100300930010TEXTO
   //
   // 1     - Rotação
   // 9     - Fonte / Código de Barras / Imagem / Gráfico
   // 1     - Multiplicador de Largura
   // 1     - Multiplicador de Altura
   // 003   - Tamanho Fonte / Altura do Código de Barras
   // 0930  - Linha
   // 0010  - Coluna
   // TEXTo - Texto a ser impresso

   nContar := nQtetq
   _cEmissao := dtos(SC5->C5_EMISSAO)//Michel Aoki 25/09/2014 - Adição da data de emissão do pedido
   _cEmissao := Substr(_cEmissao,7,2)+'/'+Substr(_cEmissao,5,2)+'/'+Substr(_cEmissao,3,2)
   // Calcula a quantidade do laço
   nLaco := Int((nQtetq / 2)) + mod(nQtetq,2)
   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek(xFilial("SC5")+cPedido) 
   
   For nEt := 1 to nLaco
       
       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))
       MSCBWRITE('H10'+chr(13))
       MSCBWRITE('D11'+chr(13))

       If nContar > 2
          MSCBWRITE("222110002000120 PEDIDO N "+_cEmissao    + chr(13))
          MSCBWRITE("243410002000040" + Alltrim(cPedido) + chr(13))
          MSCBWRITE("2a4202501500005" + Alltrim(cPedido)  + chr(13))

          MSCBWRITE("222110002000290PEDIDO N "+_cEmissao    + chr(13))
          MSCBWRITE("243410002000210" + Alltrim(cPedido) + chr(13))
          MSCBWRITE("2a4202501500175" + Alltrim(cPedido)  + chr(13))

       Else

          MSCBWRITE("222110002000120PEDIDO N "+_cEmissao    + chr(13))
          MSCBWRITE("243410002000040" + Alltrim(cPedido) + chr(13))
          MSCBWRITE("2a4202501500005" + Alltrim(cPedido)  + chr(13))

          If nQtetq == 2

             MSCBWRITE("222110002000290PEDIDO N "+_cEmissao          + chr(13))
             MSCBWRITE("243410002000210" + Alltrim(cPedido)                   + chr(13))
             MSCBWRITE("2a4202501500175" + Alltrim(cPedido)                   + chr(13))

          Endif   
       Endif             

       nContar := nContar - 1

       MSCBWRITE("Q0001"+ chr(13))
       MSCBWRITE(chr(002)+"E"+ chr(13))
       MSCBEND()

       MSCBCLOSEPRINTER()
                            
   Next nEtq
   RestArea(_aAreaSC5)
Return