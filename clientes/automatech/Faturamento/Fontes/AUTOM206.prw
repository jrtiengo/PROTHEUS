#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM206.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho                                            *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 03/02/2014                                                           *
// Objetivo..: Programa que abre tela de pesquisa de pedidos faturados e expedidos. *
//***********************************************************************************

User Function AUTOM206()

   Local lChumba       := .F.
   Local lSelecao      := .F.

   Private aVendedores := {}
   Private cComboBx1

   Private dInicial    := Ctod("  /  /    ")
   Private dFinal 	   := Ctod("  /  /    ")
   Private cCliente	   := Space(06)
   Private cLoja	   := Space(03)
   Private cNomeCli    := Space(60)
   Private cPedido     := Space(06)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlgE

   U_AUTOM628("AUTOM206")

   If __CUSERID == "000000"
      lSelecao := .T.
   Else

      // Pesquisa dados do vendedore logado
      If Select("T_DADOS") > 0
         T_DADOS->( dbCloseArea() )
      EndIf

      cSql := "" 
      cSql := "SELECT A3_CODUSR,"
      cSql += "       A3_TSTAT  "
      cSql += "  FROM " + RetSqlName("SA3")
      cSql += " WHERE A3_CODUSR  = '" + Alltrim(__CUSERID) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

      If T_DADOS->A3_TSTAT == "1"
         lSelecao := .F.
      Else
         lSelecao := .T.
      Endif

   Endif

   // Pesquisa os vendedores
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.CT_VEND  ,"
   cSql += "       B.A3_NOME  ,"
   cSql += "       B.A3_CODUSR,"
   cSql += "       B.A3_TSTAT  "
   cSql += "  FROM " + RetSqlName("SCT") + " A,"
   cSql += "       " + RetSqlName("SA3") + " B "
   cSql += " WHERE SUBSTRING(A.CT_DATA,01,04) = '" + Strzero(year(date()),4) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.CT_VEND   <> ''"
   cSql += "   AND A.CT_VEND    = B.A3_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"

   If lSelecao == .F.
      cSql += " AND B.A3_CODUSR = '" + Alltrim(__CUSERID) + "'"
   Endif         

   cSql += " ORDER BY B.A3_NOME"   
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      aVendedores := {}
   Else
      T_VENDEDOR->( DbGoTop() )
      WHILE !T_VENDEDOR->( EOF() )
         aAdd( aVendedores, IIF(Empty(Alltrim(T_VENDEDOR->A3_TSTAT)), "1", Alltrim(T_VENDEDOR->A3_TSTAT)) + "." + Alltrim(T_VENDEDOR->CT_VEND) + " - " + T_VENDEDOR->A3_NOME ) 
         T_VENDEDOR->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgE TITLE "Pesquisa Expedições" FROM C(178),C(181) TO C(364),C(612) PIXEL

   @ C(005),C(005) Say "Vendedor"           Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(029),C(005) Say "Data Inicial"       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(029),C(050) Say "Data Final"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
// @ C(029),C(120) Say "Nº Pedido de Venda" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(051),C(005) Say "Cliente"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   
   @ C(014),C(005) ComboBox cComboBx1 Items aVendedores  When lSelecao Size C(204),C(010) PIXEL OF oDlgE
   @ C(038),C(005) MsGet oGet1 Var dInicial                            Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(038),C(050) MsGet oGet2 Var dFinal                              Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
// @ C(038),C(120) MsGet oGet6 Var cPedido                             Size C(049),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(060),C(005) MsGet oGet3 Var cCliente                            Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE F3("SA1") VALID(TRACLITELA(cCliente, cLoja))
   @ C(060),C(041) MsGet oGet4 Var cLoja                               Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE VALID(TRACLITELA(cCliente, cLoja))
   @ C(060),C(062) MsGet oGet5 Var cNomeCli              When lChumba  Size C(146),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
                                                                          
   @ C(076),C(067) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgE ACTION( FATEXPEDICAO() )
   @ C(076),C(105) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// Função que pesquisa o cliente informado
Static Function TRACLITELA(_Cliente,_Loja)

   If Empty(Alltrim(_Cliente))
      cNomeCli := Space(60)
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Loja))
      cNomeCli := Space(60)
      Return(.T.)
   Endif

   cNomeCli := Posicione( "SA1", 1, xFilial("SA1") + _Cliente + _Loja, "A1_NOME" )   
   
Return(.T.)   
   
// Função que pesquisa os faturamentos e expedições conforme parâmetros
Static Function FATEXPEDICAO()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cRegistros  := 0
   Local nContar     := 0
   Local cVendedor   := Substr(cComboBx1,12)
   Local cPeriodo    := "Período de " + Dtoc(dInicial) + " até " + Dtoc(dFinal)

   Local oGet1
   Local oGet2
   Local oRegistros 
   
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private aCabeca   := {}
   Private aDetalhe  := {}
   Private oCabeca
   Private oDetalhe
   
   Private oDlgN

   // Pesquisa dados das documentos e expedições
   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT SF2.F2_FILIAL ," + CHR(13)
   cSql += "       SF2.F2_DOC    ," + CHR(13)
   cSql += "       SF2.F2_SERIE  ," + CHR(13)
   cSql += "       SF2.F2_EMISSAO," + CHR(13)
   cSql += "       SF2.F2_CLIENTE," + CHR(13)
   cSql += "       SF2.F2_LOJA   ," + CHR(13)
   cSql += "       SA1.A1_NOME   ," + CHR(13)
   cSql += "       SF2.F2_VALMERC," + CHR(13)
   cSql += "       SF2.F2_TRANSP ," + CHR(13)
   cSql += "       SA4.A4_NOME   ," + CHR(13)
   cSql += "       SF2.F2_VEND1  ," + CHR(13)
   cSql += "       SF2.F2_ESPECI1," + CHR(13)
   cSql += "       SF2.F2_VOLUME1," + CHR(13)
   cSql += "       SF2.F2_PLIQUI ," + CHR(13)
   cSql += "       SF2.F2_PBRUTO ," + CHR(13)
   cSql += "       SF2.F2_HREXPED," + CHR(13)
   cSql += "       SF2.F2_CONHECI " + CHR(13)
   cSql += "  FROM " + RetSqlName("SF2") + " SF2," + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1," + CHR(13)
   cSql += "       " + RetSqlName("SA4") + " SA4 " + CHR(13)
   cSql += " WHERE SF2.D_E_L_E_T_ = ''"  + CHR(13)

   If !Empty(dInicial)
      cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103) AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal) + "', 103)" + CHR(13)
   Endif

   If !Empty(Alltrim(cCliente))
      cSql += "   AND SF2.F2_CLIENTE = '" + Alltrim(cCliente) + "'" + CHR(13)
      cSql += "   AND SF2.F2_LOJA    = '" + Alltrim(cLoja)    + "'" + CHR(13)
   Endif

   cSql += "   AND SA1.A1_FILIAL  = ''"             + CHR(13)
   cSql += "   AND SA1.A1_COD     = SF2.F2_CLIENTE" + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SF2.F2_LOJA"    + CHR(13)
   cSql += "   AND SF2.F2_VEND1   = '" + Alltrim(Substr(cComboBx1,03,06)) + "'" + CHR(13)
   cSql += "   AND SA4.A4_FILIAL  = ''" + CHR(13)
   cSql += "   AND SA4.A4_COD     = SF2.F2_TRANSP" + CHR(13)
   cSql += " ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   T_NOTAS->( DbGoTop() )

   aCabeca := {}

   WHILE !T_NOTAS->( EOF() )

      aAdd( aCabeca, { T_NOTAS->F2_FILIAL            ,;
                       T_NOTAS->F2_DOC               ,;
                       T_NOTAS->F2_SERIE             ,;
                       Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,01,04) ,;
                       T_NOTAS->F2_CLIENTE           ,;
                       T_NOTAS->F2_LOJA              ,;
                       T_NOTAS->A1_NOME              ,;
                       STR(T_NOTAS->F2_VALMERC,10,02),;
                       T_NOTAS->F2_TRANSP            ,;
                       T_NOTAS->A4_NOME              ,;
                       T_NOTAS->F2_ESPECI1           ,;
                       STR(T_NOTAS->F2_VOLUME1,05)   ,;
                       STR(T_NOTAS->F2_PLIQUI,10,02) ,;
                       STR(T_NOTAS->F2_PBRUTO,10,02) ,;
                       T_NOTAS->F2_HREXPED           ,;
                       T_NOTAS->F2_CONHECI } )

      T_NOTAS->( DbSkip() )
      
   ENDDO

   If Len(aCabeca) == 0
      MsgAlert("Não existem dados a serem visualizados para estes parâmetros.")
      oDlgE:End()
      Return(.T.)
   Endif

   // Carrega os produtos da primeira nota fiscal para display
   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_PEDIDO ," + chr(13)
   cSql += "       A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(aCabeca[1,1]) + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(aCabeca[1,2]) + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(aCabeca[1,3]) + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   aDetalhe := {}

   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )

         aAdd( aDetalhe, { T_DETALHE->D2_PEDIDO,;
                           T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif
  
   DEFINE MSDIALOG oDlgN TITLE "Faturamento / Expedição" FROM C(178),C(181) TO C(625),C(967) PIXEL

   @ C(003),C(005) Jpeg FILE "logoautoma.bmp"                    Size C(075),C(051) PIXEL NOBORDER OF oDlgN
   @ C(004),C(199) Say "Pedidos Faturados/Expedidos do Vendedor" Size C(106),C(008) COLOR CLR_BLACK PIXEL OF oDlgN
   @ C(034),C(005) Say "Notas Fiscais"                           Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgN
   @ C(140),C(005) Say "Produtos da Nota Fiscal selecionada"     Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlgN
   @ C(210),C(005) Say "Duplo click sobre a nota fiscal para visualizar os produtos do documento" Size C(172),C(008) COLOR CLR_RED PIXEL OF oDlgN

   @ C(013),C(199) MsGet oGet1 Var cVendedor When lChumba Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgN
   @ C(027),C(199) MsGet oGet2 Var cPeriodo  When lChumba Size C(188),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgN

   @ C(207),C(350) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgN ACTION( oDlgE:End(), oDlgN:End() )

   @ 055,005 LISTBOX oCabeca FIELDS HEADER "Fl", "N.Fiscal" ,"Série", "Emissão", "Cliente", "Loja", "Descrição dos Clientes", "Total", "Transp.", "Nome Transp.", "Espécie", "Volumes", "Peso Liq.", "Peso Bruto", "Hora Exp.", "Conhecimento" PIXEL SIZE 490,120 OF oDlgN ;
                             ON dblClick(aCabeca[oCabeca:nAt,1] := !aCabeca[oCabeca:nAt,1],oCabeca:Refresh())     

   oCabeca:SetArray( aCabeca )
   oCabeca:bLine := {||     {aCabeca[oCabeca:nAt,01],;
           		    	     aCabeca[oCabeca:nAt,02],;
         	         	     aCabeca[oCabeca:nAt,03],;
         	         	     aCabeca[oCabeca:nAt,04],;
         	         	     aCabeca[oCabeca:nAt,05],;
         	         	     aCabeca[oCabeca:nAt,06],;
         	         	     aCabeca[oCabeca:nAt,07],;
         	         	     aCabeca[oCabeca:nAt,08],;
         	         	     aCabeca[oCabeca:nAt,09],;
         	         	     aCabeca[oCabeca:nAt,10],;
         	         	     aCabeca[oCabeca:nAt,11],;
         	         	     aCabeca[oCabeca:nAt,12],;
         	         	     aCabeca[oCabeca:nAt,13],;
         	         	     aCabeca[oCabeca:nAt,14],;
         	         	     aCabeca[oCabeca:nAt,15],;
         	         	     aCabeca[oCabeca:nAt,16]}}

   oCabeca:bLDblClick := {|| QUEPRODUTO(aCabeca[oCabeca:nAt,01], aCabeca[oCabeca:nAt,02], aCabeca[oCabeca:nAt,03]) } 

   @ 190,005 LISTBOX oDetalhe FIELDS HEADER "Pedido", "Item", "Código", "Descrição dos Produtos" , "Und", "Qtd.", "Unitário", "Total" PIXEL SIZE 490,070 OF oDlgN ;
                              ON dblClick(aDetalhe[oDetalhe:nAt,1] := !aDetalhe[oDetalhe:nAt,1],oDetalhe:Refresh())     

   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
         		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07],;
          		    		  aDetalhe[oDetalhe:nAt,08]}}
   oDetalhe:Refresh()

   ACTIVATE MSDIALOG oDlgN CENTERED 
   
Return(.T.)

// Função que pesquisa as notas fiscais do cliente informado
Static Function queproduto(_Filial, _Nota, _Serie)

   Local cSql 

   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_PEDIDO ," + chr(13)
   cSql += "       A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(_Filial)  + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(_Nota)    + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(_Serie)   + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )

         aAdd( aDetalhe, { T_DETALHE->D2_PEDIDO,;
                           T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif

   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
          		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07],;
          		    		  aDetalhe[oDetalhe:nAt,08]}}
   oDetalhe:Refresh()
   
Return(.T.)