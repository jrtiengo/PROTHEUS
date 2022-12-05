#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM276.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/03/2015                                                          *
// Objetivo..: Impressão Etiqueta com o nº do Pedido de Venda.                     *
// Parâmetros: < _Ordem > - Nº da Ordem de Serviço                                 *
//**********************************************************************************

// Função que define a Window
User Function AUTOM276(_Ordem)

   Local lChumba      := .F.
   Local cMemo1	      := ""
   Local oMemo1
   
   Private aPortas    := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cPortas    := "COM1"
   Private cOrdem	  := Space(06)
   Private cCliente   := Space(100)
   Private cPedido 	  := Space(06)
   Private cEtiquetas := 1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   // Veririca se a Ordem de Serviço informada possui pedido de venda associado
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT SC6.C6_NUM ,
   cSql += "                SC6.C6_CLI ,
   cSql += "                SC6.C6_LOJA,
   cSql += "                SA1.A1_NOME
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SUBSTRING(SC6.C6_NUMOS, 01,06) = '" + Alltrim(_Ordem)  + "'"
   cSql += "   AND SUBSTRING(SC6.C6_NUMOS, 07,02) = '" + Alltrim(cFilial) + "'"
   cSql += "   AND SC6.D_E_L_E_T_                 = ''"
   cSql += "   AND SA1.A1_COD                     = SC6.C6_CLI "
   cSql += "   AND SA1.A1_LOJA                    = SC6.C6_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_                 = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )
 
   If T_PEDIDO->( EOF() )
      MsgAlert("Pedido de Venda para esta Ordem de Serviço não localizada. Verifique!")
      Return(.T.)
   Endif
   
   cOrdem	  := _Ordem
   cCliente   := Alltrim(T_PEDIDO->C6_CLI) + "." + Alltrim(T_PEDIDO->C6_LOJA) + " - " + Alltrim(T_PEDIDO->A1_NOME)
   cPedido 	  := T_PEDIDO->C6_NUM

   // Deseha a tela de impressão da etiqueta
   DEFINE MSDIALOG oDlg TITLE "Etiqueta de Pedido de Venda de OS" FROM C(178),C(181) TO C(395),C(668) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlg

   @ C(038),C(005) Say "Nº O.S."            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(040) Say "Cliente"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(038),C(195) Say "Nº Pedido Venda"    Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(040) Say "Qtd Etiqueta"       Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(079) Say "Porta de Impressão" Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) MsGet    oGet1   Var   cOrdem     Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(047),C(040) MsGet    oGet2   Var   cCliente   Size C(149),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(047),C(195) MsGet    oGet3   Var   cPedido    Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(071),C(040) MsGet    oGet4   Var   cEtiquetas Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(071),C(078) ComboBox cPortas Items aPortas    Size C(112),C(010) PIXEL OF oDlg

   @ C(090),C(081) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( ImpEtqOS(cPedido, cEtiquetas, cPortas, cOrdem)  )
   @ C(090),C(119) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que imprime a etiqueta
static function ImpEtqOS(_xPedido, _xQuantidade, _xPortas, _xOrdem)

   Local cPorta    := _xPortas
   Local nQtetq    := _xQuantidade
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

   // Pesquisa a data de Emissão do Pedido de Venda
   _cEmissao := Dtos(Posicione("SC5", 1, xFilial("SC5") + cPedido, "C5_EMISSAO"))
   _cEmissao := Substr(_cEmissao,7,2)+'/'+Substr(_cEmissao,5,2)+'/'+Substr(_cEmissao,3,2)

   nContar := nQtetq

   // Calcula a quantidade do laço
   nLaco := Int((nQtetq / 2)) + mod(nQtetq,2)
   
   For nEt := 1 to nLaco
       
       MSCBPRINTER("DATAMAX",cPorta)
       MSCBCHKSTATUS(.F.)
       MSCBBEGIN(2,6,) 
       MSCBWRITE(chr(002)+'L'+chr(13))
       MSCBWRITE('H10'+chr(13))
       MSCBWRITE('D11'+chr(13))

       If nContar > 2

          MSCBWRITE("221100502000120OS:"                          + chr(13))
          MSCBWRITE("222300501800100"          + _xOrdem          + chr(13))
          MSCBWRITE("221100502000080DATA:"                        + chr(13))
          MSCBWRITE("221100501600080"          + _cEmissao        + chr(13))
          MSCBWRITE("221100502000065PEDIDO Nr"                    + chr(13))
          MSCBWRITE("222300501600035"          + cPedido          + chr(13))
          MSCBWRITE("2e2302002000015"          + Alltrim(cPedido) + chr(13))

          MSCBWRITE("221100502000285OS:"                          + chr(13))
          MSCBWRITE("222300501800265"          + _xOrdem          + chr(13))
          MSCBWRITE("221100502000250DATA:"                        + chr(13))
          MSCBWRITE("221100501600250"          + _cEmissao        + chr(13))
          MSCBWRITE("221100502000235PEDIDO Nr"                    + chr(13))
          MSCBWRITE("222300501600205"          + cPedido          + chr(13))
          MSCBWRITE("2e2302002000180"          + Alltrim(cPedido) + chr(13))

       Else

          MSCBWRITE("221100502000120OS:"                          + chr(13))
          MSCBWRITE("222300501800100"          + _xOrdem          + chr(13))
          MSCBWRITE("221100502000080DATA:"                        + chr(13))
          MSCBWRITE("221100501600080"          + _cEmissao        + chr(13))
          MSCBWRITE("221100502000065PEDIDO Nr"                    + chr(13))
          MSCBWRITE("222300501600035"          + cPedido          + chr(13))
          MSCBWRITE("2e2302002000015"          + Alltrim(cPedido) + chr(13))

          If nQtetq == 2
                                                                 
             MSCBWRITE("221100502000285OS:"                          + chr(13))
             MSCBWRITE("222300501800265"          + _xOrdem          + chr(13))
             MSCBWRITE("221100502000250DATA:"                        + chr(13))
             MSCBWRITE("221100501600250"          + _cEmissao        + chr(13))
             MSCBWRITE("221100502000235PEDIDO Nr"                    + chr(13))
             MSCBWRITE("222300501600205"          + cPedido          + chr(13))
             MSCBWRITE("2e2302002000180"          + Alltrim(cPedido) + chr(13))

          Endif   

       Endif             

       nContar := nContar - 1

       MSCBWRITE("Q0001" + chr(13))
       MSCBWRITE(chr(002) + "E" + chr(13))
       MSCBEND()

       MSCBCLOSEPRINTER()
                            
   Next nEtq

   RestArea(_aAreaSC5)
           
   oDlg:End() 

Return(.T.)