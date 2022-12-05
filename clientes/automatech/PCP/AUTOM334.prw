#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM334.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 19/02/2016                                                              ##
// Objetivo..: Programa que imprime etiquetas de produtos para Filial 04 - Suprimentos ##
// ######################################################################################

User Function AUTOM334()
           
   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1

   Private aFilial   := U_AUTOM539(2, cEmpAnt) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private cComboBx1

   Private cOrdem    := Space(006)
   Private cCliente  := Space(250)
   Private oGet1
   Private oGet2

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private oDlg

   Private aLista := {}
   Private oLista

   aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "" })           

// cComboBx1 := "04 - Suprimentos"

   DEFINE MSDIALOG oDlg TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(604),C(1050) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(431),C(001) PIXEL OF oDlg

   @ C(040),C(005) Say "Filial"                                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(100) Say "Nº OP"                                  Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(140) Say "Cliente"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(062),C(005) Say "Produto(s) da(s) Ordem(ns) de Produção" Size C(097),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(005) ComboBox cComboBx1   Items aFilial           Size C(088),C(010)                              PIXEL OF oDlg
   @ C(049),C(100) MsGet  oGet1         Var   cOrdem            Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(049),C(140) MsGet  oGet2         Var   cCliente          Size C(245),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(397) Button "Pesquisar"                           Size C(037),C(012)                              PIXEL OF oDlg ACTION( PesqOrdemPro() )
   @ C(198),C(005) Button "Marcar Todos"                        Size C(052),C(012) PIXEL OF oDlg ACTION( MMTodos(1) )
   @ C(198),C(061) Button "Desmarcar Todos"                     Size C(052),C(012) PIXEL OF oDlg ACTION( MMTodos(2) )
   @ C(198),C(150) Button "Altera Quantidade de Impressão"      Size C(083),C(012) PIXEL OF oDlg ACTION( AltQtdEtq(aLista[oLista:nAt,02], aLista[oLista:nAt,03], aLista[oLista:nAt,04], aLista[oLista:nAt,06], aLista[oLista:nAt,07], aLista[oLista:nAt,09]) )
   @ C(198),C(267) Button "Imprimir"                            Size C(049),C(012) PIXEL OF oDlg ACTION( ImpEtqmarcadas() )

   @ C(198),C(317) Button "Etq. Avulsa"                         Size C(049),C(012) PIXEL OF oDlg ACTION( xAvulsas() )

   @ C(198),C(397) Button "Voltar"                              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:eND() )

   // Lista com os produtos da Ordem de Produção
   @ 090,005 LISTBOX oLista FIELDS HEADER "M"                     ,;
                                          "Nº O.Produção"         ,;
                                          "Item"                  ,;
                                          "Seq"                   ,;
                                          "Data OP"               ,;
                                          "Código"                 + Space(15),;
                                          "Descrição dos Produtos" + Space(20),;
                                          "Und"                   ,;
                                          "Qtd OP"                ,;
                                          "Etq.p/Rolo"            ,;
                                          "Etq a Imprimir" PIXEL SIZE 549,160 OF oDlg ;
             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]             ,;
                            aLista[oLista:nAt,03]             ,;
                            aLista[oLista:nAt,04]             ,;
                            aLista[oLista:nAt,05]             ,;
                            aLista[oLista:nAt,06]             ,;
                            aLista[oLista:nAt,07]             ,;
                            aLista[oLista:nAt,08]             ,;
                            aLista[oLista:nAt,09]             ,;
                            aLista[oLista:nAt,10]             ,;
                            aLista[oLista:nAt,11]             }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #########################################
// Função que marca/desmarca os registros ##
// #########################################
Static Function MMTodos(__Opcao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(__Opcao == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// #################################################################
// Função que pesquisa os produtos da Ordem de Produção informada ##
// #################################################################
Static Function PesqOrdemPro()
                            
   Local cSql   := ""
   Local _aRet1 := {}

   If Empty(alltrim(cOrdem))
      Return(.T.)
   Endif
      
   aLista := {}

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SC2.C2_FILIAL ,"
   cSql += "       SC2.C2_NUM    ,"
   cSql += "       SC2.C2_OBS    ,"
   cSql += "       SC2.C2_PEDIDO ,"
   cSql += "       SC2.C2_ITEM   ,"
   cSql += "       SC2.C2_SEQUEN ,"
   cSql += "       SC2.C2_DATPRF ,"
   cSql += "	   SC2.C2_PRODUTO,"
   cSql += "	   LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS DESCRICAO,"
   cSql += "	   SC2.C2_UM     ,"
   cSql += "       SC2.C2_QUANT  ,"
   cSql += "      (SC2.C2_QUANT + ((SC2.C2_QUANT * 10/100))) AS QTDM10"
   cSql += "  FROM " + RetSqlName("SC2") + " SC2, " 
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SC2.C2_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SC2.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_COD     = SC2.C2_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SC2.C2_NUM     = '" + Alltrim(cOrdem) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para esta ordem de produção.")
      aLista := {}
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "" })
      Return(.T.)
   Endif
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )

      _aRet1 := U_CALCMETR(T_PRODUTOS->C2_PRODUTO)

      If Alltrim(T_PRODUTOS->C2_UM) == "RL"
         xQuantidade := T_PRODUTOS->C2_QUANT * _aRet1[2]
         xEtiquetas  := T_PRODUTOS->C2_QUANT
      Else
         xQuantidade := T_PRODUTOS->C2_QUANT
         xEtiquetas  := Int((T_PRODUTOS->C2_QUANT * 1000) / _aRet1[2])
      Endif   
   
      aAdd( aLista, { .F.                   ,;
                      T_PRODUTOS->C2_NUM    ,;
                      T_PRODUTOS->C2_ITEM   ,;
                      T_PRODUTOS->C2_SEQUEN ,;
                      Substr(T_PRODUTOS->C2_DATPRF,07,02) + "/" + Substr(T_PRODUTOS->C2_DATPRF,05,02) + "/" + Substr(T_PRODUTOS->C2_DATPRF,01,04) ,;
                      T_PRODUTOS->C2_PRODUTO,;
                      T_PRODUTOS->DESCRICAO ,;
                      T_PRODUTOS->C2_UM     ,;
                      xQuantidade           ,;
                      _aRet1[2]             ,;
                      xEtiquetas            })

       T_PRODUTOS->( DbSkip() )                      
       
   Enddo
    
   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "" })
   Endif

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]             ,;
                            aLista[oLista:nAt,03]             ,;
                            aLista[oLista:nAt,04]             ,;
                            aLista[oLista:nAt,05]             ,;
                            aLista[oLista:nAt,06]             ,;
                            aLista[oLista:nAt,07]             ,;
                            aLista[oLista:nAt,08]             ,;
                            aLista[oLista:nAt,09]             ,;
                            aLista[oLista:nAt,10]             ,;
                            aLista[oLista:nAt,11]             }}

Return(.T.)

// ###########################################
// Função que imprime as etiquetas marcadas ##
// ###########################################
Static Function ImpEtqmarcadas()

   Local nContar    := 0
   Local lMarcados  := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private aPortas   := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cPorta

   Private oDlgPrn
   
   // #####################################################################
   // Verifica se houve marcação de pelo menos um regsitro para impresão ##
   // #####################################################################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Nenhum registro foi marcado para impressão. Verifique!")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgPrn TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(342),C(480) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgPrn

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(142),C(001) PIXEL OF oDlgPrn

   @ C(040),C(005) Say "Portas de Impressão" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgPrn

   @ C(049),C(005) ComboBox cPorta Items aPortas Size C(141),C(010) PIXEL OF oDlgPrn

   @ C(065),C(037) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgPrn ACTION( PrnEtiquetas() )
   @ C(065),C(075) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPrn ACTION( oDlgPrn:End() )

   ACTIVATE MSDIALOG oDlgPrn CENTERED 

Return(.T.)

// ###########################################
// Função que imprime as etiquetas marcadas ##
// ###########################################
Static Function PrnEtiquetas()
                
   Local nContar := 0
   Local cString := ""

   oDlgPrn:End()

   For nContar = 1 to Len(aLista)
    
       If aLista[nContar,01] == .T.
       
          // ################################################
          // Prepara a descrição do produto para impressão ##
          // ################################################
          xNome_Produto  := Alltrim(aLista[nContar,07]) + Space(60 - Len(Alltrim(aLista[nContar,07])))
          x01_Nome_Linha := Substr(xNome_Produto,01,30)
          x02_Nome_Linha := Substr(xNome_Produto,31)

          MSCBPRINTER("ZEBRA",cPorta)
          MSCBCHKSTATUS(.F.)
          MSCBBEGIN(2,6,) 

          MSCBWRITE("CT~~CD,~CC^~CT~" + CHR(13))
          MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ" + CHR(13))
          MSCBWRITE("^XA"     + CHR(13))
          MSCBWRITE("^MMT"    + CHR(13))
          MSCBWRITE("^PW639"  + CHR(13))
          MSCBWRITE("^LL0240" + CHR(13))
          MSCBWRITE("^LS0"    + CHR(13))

// - Impressão código de barras anterior    
//        MSCBWRITE("^BY2,3,49^FT37,194^BCN,,Y,N" + CHR(13))
//        MSCBWRITE("^FD>;" + aLista[nContar,06] + ">60^FS" + CHR(13))

// - Impressão novo cpodigo de barras
//        MSCBWRITE("^BY2,3,57^FT37,204^BCN,,Y,N" + CHR(13))
//        MSCBWRITE("^FD>;" + aLista[nContar,06] + "^FS" + CHR(13))

          // #################################################
          // Prepara o código para gerar o Código de Barras ##
          // #################################################
          Do Case
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "0"
                  nFinal := "60"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "1"
                  nFinal := "61"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "2"
                  nFinal := "62"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "3"
                  nFinal := "63"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "4"
                  nFinal := "64"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "5"
                  nFinal := "65"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "6"
                  nFinal := "66"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "7"
                  nFinal := "67"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "8"
                  nFinal := "68"
             Case Substr(Alltrim(aLista[nContar,06]),Len(Alltrim(aLista[nContar,06])),1) == "9"
                  nFinal := "69"
          EndCase           

          MSCBWRITE("^BY2,3,59^FT84,209^BCN,,Y,N" + CHR(13))
          MSCBWRITE("^FD>;" + Alltrim(aLista[nContar,06]) + ">" + nFinal + "^FS" + CHR(13))

          MSCBWRITE("^FT513,116^A0R,20,19^FH\^FDVal.: 01 ano^FS" + CHR(13))
          MSCBWRITE("^FT311,125^A0N,20,19^FH\^FDVal.: 01 ano^FS" + CHR(13))

          /* 
          MSCBWRITE("^FT512,18^A0R,20,19^FH\^FD"  + aLista[nContar,05] + "^FS" + CHR(13))
          MSCBWRITE("^FT213,126^A0N,20,19^FH\^FD" + aLista[nContar,05] + "^FS" + CHR(13))
          */

         //Ajuste na impressão da DATA - Sosys - Tiengo 
          MSCBWRITE("^FT512,18^A0R,20,19^FH\^FD"  + DtoC(Date()) + "^FS" + CHR(13))
          MSCBWRITE("^FT213,126^A0N,20,19^FH\^FD" + DtoC(Date()) + "^FS" + CHR(13))
          
          MSCBWRITE("^FT535,49^A0R,28,28^FH\^FD"  + Transform(aLista[nContar,10],"@E 999,999,999") + " UN" + "^FS" + CHR(13))

          // Segunda linha da descrição do produto (posições restantes acima da posição 31)
          MSCBWRITE("^FT34,94^A0N,23,24^FH\^FD"  + x02_Nome_Linha + "^FS" + CHR(13))
          MSCBWRITE("^FT34,134^A0N,34,28^FH\^FD" + Transform(aLista[nContar,10],"@E 999,999,999") + " UN" + " ^FS" + CHR(13))
          MSCBWRITE("^FT565,16^A0R,23,24^FH\^FD" + aLista[nContar,06] + "^FS" + CHR(13))
          MSCBWRITE("^FT592,67^A0R,23,24^FH\^FD" + Alltrim(aLista[nContar,02]) + "." + Alltrim(aLista[nContar,03]) + "." + Alltrim(aLista[nContar,04]) + "^FS" + CHR(13))

          // Nº da Oprdem de Produção
          MSCBWRITE("^FT591,19^A0R,23,24^FH\^FDOP:^FS" + CHR(13))
          MSCBWRITE("^FT76,35^A0N,23,24^FH\^FD" + Alltrim(aLista[nContar,02]) + "." + Alltrim(aLista[nContar,03]) + "." + Alltrim(aLista[nContar,04]) + "^FS" + CHR(13))

          // Primeira linha da descrição do produto (30 posições)
          MSCBWRITE("^FT32,34^A0N,23,24^FH\^FDOP:^FS" + CHR(13))
          MSCBWRITE("^FT32,64^A0N,23,24^FH\^FD" + x01_Nome_Linha + "^FS" + CHR(13))

          MSCBWRITE("^PQ" + Alltrim(Str(aLista[nContar,11])) + ",0,1,Y^XZ" + CHR(13))
          MSCBEND()
          MSCBCLOSEPRINTER()

       Endif
       
   Next nContar
   
Return(.T.)

// #########################################################################
// Função que permite alterar a quantidade de etiquetas a serem impressas ##
// #########################################################################
Static Function AltQtdEtq(_Ordem, _Item, _Sequencia, _Codigo, _Descricao, _Quantidade)

   Local lChumba     := .F.
   Local nContar     := 0
   Local cDescricao  := Alltrim(_Codigo) + " - " + Alltrim(_Descricao)
   Local cPorRolo    := 0
   Local cImprimir 	 := 0
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oGet2
   Local oGet3
   Local oGet4
   Local oMemo1
   Local oMemo2

   Private oDlgQtd

   If Len(Alltrim(_Codigo)) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgQtd TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(395),C(683) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgQtd

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(244),C(001) PIXEL OF oDlgQtd
   @ C(086),C(003) GET oMemo2 Var cMemo2 MEMO Size C(244),C(001) PIXEL OF oDlgQtd
   
   @ C(040),C(005) Say "Produto"             Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgQtd
   @ C(062),C(005) Say "Qtd Etq p/Rolo"      Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgQtd
   @ C(062),C(045) Say "Qtd Etq p/Impressão" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgQtd

   @ C(049),C(005) MsGet oGet2 Var cDescricao Size C(240),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgQtd When lChumba
   @ C(072),C(005) MsGet oGet3 Var cPorRolo   Size C(034),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgQtd
   @ C(072),C(045) MsGet oGet4 Var cImprimir  Size C(034),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgQtd

   @ C(092),C(208) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgQtd ACTION( EncerraQtd(_Ordem, _Item, _Sequencia, _Codigo, cPorRolo, cImprimir) )

   ACTIVATE MSDIALOG oDlgQtd CENTERED 

Return(.T.)

// ##############################################################
// Função que encerra a alteração da quantidade a ser impressa ##
// ##############################################################
Static Function EncerraQtd(_Ordem, _Item, _Sequencia, _Codigo, _Quantidade, cNovaQtd)

   Local nContar := 0
 
   If cNovaQtd == 0
      cNovaQtd := _Quantidade
   Endif

   For nContar = 1 to Len(aLista)
       If aLista[nContar,02] == _Ordem     .And. ;
          aLista[nContar,03] == _Item      .And. ;
          aLista[nContar,04] == _Sequencia .And. ;
          aLista[nContar,06] == _Codigo
          aLista[nContar,10] := _Quantidade
          aLista[nContar,11] := cNovaQtd          
          Exit
       Endif
   Next nContar

   oDlgQtd:End()
          
   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]             ,;
                            aLista[oLista:nAt,03]             ,;
                            aLista[oLista:nAt,04]             ,;
                            aLista[oLista:nAt,05]             ,;
                            aLista[oLista:nAt,06]             ,;
                            aLista[oLista:nAt,07]             ,;
                            aLista[oLista:nAt,08]             ,;
                            aLista[oLista:nAt,09]             ,;
                            aLista[oLista:nAt,10]             ,;
                            aLista[oLista:nAt,11]             }}

Return(.T.)

// #######################################
// Função que imprime etiquetas avulsas ##
// #######################################
Static Function xAvulsas()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private kProduto    := Space(30)
   Private kDescricao  := Space(60)
   Private kQuantidade := 0
   Private kData  	   := Ctod("  /  /    ")
   Private kRolos      := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   
   Private oDlgAV

   DEFINE MSDIALOG oDlgAV TITLE "Emissão Etiqueta Avulsa" FROM C(178),C(181) TO C(334),C(590) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(022) PIXEL NOBORDER OF oDlgAV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(199),C(001) PIXEL OF oDlgAV

   @ C(032),C(005) Say "Produto"    Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV
   @ C(054),C(005) Say "Quantidade" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV
   @ C(054),C(041) Say "Data"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV
   @ C(054),C(080) Say "Qtd Rolos"  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgAV

   @ C(041),C(005) MsGet oGet1 Var kProduto    Size C(060),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgAV F3("SB1") VALID(PSQAVULSA() )
   @ C(041),C(069) MsGet oGet2 Var kDescricao  Size C(131),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgAV When lChumba
   @ C(063),C(005) MsGet oGet3 Var kQuantidade Size C(026),C(009) COLOR CLR_BLACK Picture "@E 99999"      PIXEL OF oDlgAV
   @ C(063),C(041) MsGet oGet4 Var kData       Size C(037),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgAV
   @ C(063),C(080) MsGet oGet5 Var kRolos      Size C(037),C(009) COLOR CLR_BLACK Picture "@E 9999999999" PIXEL OF oDlgAV

   @ C(060),C(123) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgAV ACTION( ImpEtqAvulsas() )
   @ C(060),C(162) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgAV ACTION( oDlgAV:End() )

   ACTIVATE MSDIALOG oDlgAV CENTERED 

Return(.T.)

// #######################################################
// Função que pesquisa a descrição do produto informado ##
// #######################################################
Static Function PsqAvulsa()

   If Empty(Alltrim(kProduto))
      kDescricao := Space(60)
      oGet2:Refresh()
      Return(.T.)
   Endif
   
   kDescricao := POSICIONE("SB1", 1, XFILIAL("SB1") + kProduto,"B1_DESC") + ' ' + POSICIONE("SB1", 1, XFILIAL("SB1") + kProduto,"B1_DAUX")
   
   If Empty(Alltrim(kDescricao))
      kDescricao := Space(60)
      oGet2:Refresh()
      Return(.T.)
   Endif

Return(.T.)   

// ##########################################
// Função que imprime as etiquetas avulsas ##
// ##########################################
Static Function ImpEtqAvulsas()

   Local nContar    := 0
   Local lMarcados  := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private aPortas   := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cPorta

   Private oDlgPrn
   
   If kQuantidade == 0
      MsgAlert("Quantidade de etiquetas a serem impressas não informada. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(kData)
      MsgAlert("Campo Data não informado. Verifique!")
      Return(.T.)
   Endif

   If kRolos == 0
      MsgAlert("Quantidade de rolos não informado. Verifique!")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgPrn TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(342),C(480) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgPrn

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(142),C(001) PIXEL OF oDlgPrn

   @ C(040),C(005) Say "Portas de Impressão" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgPrn

   @ C(049),C(005) ComboBox cPorta Items aPortas Size C(141),C(010) PIXEL OF oDlgPrn

   @ C(065),C(037) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgPrn ACTION( PrnAvulsas() )
   @ C(065),C(075) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPrn ACTION( oDlgPrn:End() )

   ACTIVATE MSDIALOG oDlgPrn CENTERED 

Return(.T.)

// ##########################################
// Função que imprime as etiquetas avulsas ##
// ##########################################
Static Function PrnAvulsas()
                
   Local nContar := 0
   Local cString := ""

   oDlgPrn:End() 
   oDlgAV:End()

   // ################################################
   // Prepara a descrição do produto para impressão ##
   // ################################################
   xNome_Produto  := Alltrim(kDescricao) + Space(60 - Len(Alltrim(kDescricao)))
   x01_Nome_Linha := Substr(xNome_Produto,01,30)
   x02_Nome_Linha := Substr(xNome_Produto,31)

   MSCBPRINTER("ZEBRA",cPorta)
   MSCBCHKSTATUS(.F.)
   MSCBBEGIN(2,6,) 

   MSCBWRITE("CT~~CD,~CC^~CT~" + CHR(13))
   MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ" + CHR(13))
   MSCBWRITE("^XA"     + CHR(13))
   MSCBWRITE("^MMT"    + CHR(13))
   MSCBWRITE("^PW639"  + CHR(13))
   MSCBWRITE("^LL0240" + CHR(13))
   MSCBWRITE("^LS0"    + CHR(13))

   // ################################################### 
   // Prepara o código a ser gerado o Código de Barras ##
   // ###################################################
   Do Case
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "0"
           nFinal := "60"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "1"
           nFinal := "61"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "2"
           nFinal := "62"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "3"
           nFinal := "63"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "4"
           nFinal := "64"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "5"
           nFinal := "65"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "6"
           nFinal := "66"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "7"
           nFinal := "67"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "8"
           nFinal := "68"
      Case Substr(kProduto,Len(Alltrim(kProduto)),1) == "9"
           nFinal := "69"
    EndCase           

   // #############################
   // Impressão código de barras ##
   // #############################
   MSCBWRITE("^BY2,3,59^FT84,209^BCN,,Y,N" + CHR(13))
   MSCBWRITE("^FD>;" + Alltrim(kProduto) + ">" + nFinal + "^FS" + CHR(13))

   MSCBWRITE("^FT513,116^A0R,20,19^FH\^FDVal.: 01 ano^FS" + CHR(13))
   MSCBWRITE("^FT311,125^A0N,20,19^FH\^FDVal.: 01 ano^FS" + CHR(13))

   MSCBWRITE("^FT512,18^A0R,20,19^FH\^FD"  + Dtoc(kData) + "^FS" + CHR(13))
   MSCBWRITE("^FT213,126^A0N,20,19^FH\^FD" + Dtoc(kData) + "^FS" + CHR(13))

   MSCBWRITE("^FT535,49^A0R,28,28^FH\^FD"  + Transform(kRolos,"@E 999,999,999") + " UN" + "^FS" + CHR(13))

   // #################################################################################
   // Segunda linha da descrição do produto (posições restantes acima da posição 31) ##
   // #################################################################################
   MSCBWRITE("^FT34,94^A0N,23,24^FH\^FD"  + x02_Nome_Linha + "^FS" + CHR(13))
   MSCBWRITE("^FT34,134^A0N,34,28^FH\^FD" + Transform(kRolos,"@E 999,999,999") + " UN" + " ^FS" + CHR(13))
   MSCBWRITE("^FT565,16^A0R,23,24^FH\^FD" + Alltrim(kProduto) + "^FS" + CHR(13))

   // #######################################################
   // Primeira linha da descrição do produto (30 posições) ##
   // #######################################################
   MSCBWRITE("^FT32,34^A0N,23,24^FH\^FDOP:^FS" + CHR(13))
   MSCBWRITE("^FT32,64^A0N,23,24^FH\^FD" + x01_Nome_Linha + "^FS" + CHR(13))

   MSCBWRITE("^PQ" + Alltrim(Str(kQuantidade)) + ",0,1,Y^XZ" + CHR(13))
   MSCBEND()
   MSCBCLOSEPRINTER()
   
Return(.T.)
