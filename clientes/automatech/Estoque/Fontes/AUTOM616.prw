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
// Referencia: AUTOM616.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 16/08/2016                                                              ##
// Objetivo..: Programa que imprime etiquetas para Correio                             ##
// ######################################################################################

User Function AUTOM616()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aFiliais := U_AUTOM539(2, cEmpAnt)
   Private aStatus 	:= {"1 - A Imprimir", "2 - Impressas", "3 - Ambas"}
   Private cDataIni	:= Ctod("  /  /    ")
   Private cDataFim	:= Ctod("  /  /    ")
   Private cNota	:= Space(09)
   Private cSerie	:= Space(03)

   Private cComboBx1
   Private cComboBx2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   U_AUTOM628("AUTOM616")

   DEFINE MSDIALOG oDlg TITLE "Emissão de Etiquetas Correios" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg
   @ C(189),C(005) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(189),C(053) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(189),C(117) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(189),C(200) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(189),C(292) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(203),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Filial"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(059) Say "Dta Emis. Inicial"              Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(103) Say "Dta Emis. Final"                Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(146) Say "N.Fiscal"                       Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(188) Say "Série"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(210) Say "Status"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(178),C(005) Say "Legenda Etiqueta"               Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(178),C(117) Say "Legenda Endereço de Entrega"    Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(190),C(016) Say "Etq. Impressa"                  Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(190),C(064) Say "Etq. Não Impressa"              Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg    
   @ C(190),C(129) Say "Endereço Igual do Cadastro"     Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(190),C(212) Say "Endereço Diferente do Cadastro" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(190),C(306) Say "Endereço Entrega em Branco. Será utilizdo o endereço do cadastro" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aFiliais Size C(049),C(010)                              PIXEL OF oDlg
   @ C(046),C(059) MsGet    oGet1     Var   cDataIni Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(103) MsGet    oGet2     Var   cDataFim Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(146) MsGet    oGet3     Var   cNota    Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(188) MsGet    oGet4     Var   cSerie   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(210) ComboBox cComboBx2 Items aStatus  Size C(063),C(010)                              PIXEL OF oDlg

   @ C(043),C(279) Button "Pesquisar"          Size C(037),C(012) PIXEL OF oDlg ACTION( EtqNFCorreios() ) 
   @ C(210),C(005) Button "Marca Todos"        Size C(050),C(012) PIXEL OF oDlg ACTION( MMDDBBMM(1) ) When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(056) Button "Desmarca Todos"     Size C(050),C(012) PIXEL OF oDlg ACTION( MMDDBBMM(0) )When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(107) Button "Valor Declarado"    Size C(050),C(012) PIXEL OF oDlg ACTION( IIF(aLista[oLista:nAt,03] == " ", aLista[oLista:nAt,03] := "X", aLista[oLista:nAt,03] := " ") )When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(158) Button "Altera Serviço ECT" Size C(050),C(012) PIXEL OF oDlg ACTION( xAltSrvECT() ) When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(209) Button "Altera Endereço"    Size C(050),C(012) PIXEL OF oDlg ACTION( AltEndereco() ) When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(260) Button "Imprimir Etiquetas" Size C(050),C(012) PIXEL OF oDlg ACTION( ImpEtqCorreios() ) When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(311) Button "Exportar Etiquetas" Size C(050),C(012) PIXEL OF oDlg ACTION( xGravaEtq() ) When !Empty(Alltrim(aLista[oLista:nAt,05]))
   @ C(210),C(362) Button "Gera Arq.C.Postal"  Size C(050),C(012) PIXEL OF oDlg ACTION( xGeraCPostal() )
   @ C(210),C(413) Button "Importa Arq. CP"    Size C(050),C(012) PIXEL OF oDlg ACTION( ImpCodPLP() )
   @ C(210),C(464) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "0", "", "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   // ############################
   // Cria o cabeçalho da Lista ##
   // ############################
   @ 080,005 LISTBOX oLista FIELDS HEADER "M"                        ,; // 01
                                          "LG"                       ,; // 02
                                          "VD"                       ,; // 03
                                          "End"                      ,; // 04
                                          "Nº NFiscal"               ,; // 05
                                          "Série"                    ,; // 06
                                          "Emissão"                  ,; // 07
                                          "Vlr Total NF"             ,; // 08 
                                          "Nº PVenda"                ,; // 09
                                          "Tipo Serviço ECT"         ,; // 10
                                          "Cliente"                  ,; // 11
                                          "Loja"                     ,; // 12
                                          "Descrição dos Clientes"   ,; // 13
                                          "Cidade"                   ,; // 14
                                          "Estado"                   ,; // 15
                                          "Vendedor"                 ,; // 16
                                          "Descrição dos Vendedores" ,; // 17
                                          "Código Postal"            ,; // 18
                                          "Peso Líquido"              ; // 19
             PIXEL SIZE 633,145 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                             If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                             If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,02] == "9", oPink     ,;
                             If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
                                aLista[oLista:nAt,03]                   ,;
                             If(aLista[oLista:nAt,04] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,04] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,04] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,04] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,04] == "5", oAzul     ,;                         
                             If(aLista[oLista:nAt,04] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,04] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,04] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,04] == "9", oPink     ,;
                             If(aLista[oLista:nAt,04] == "4", oEncerra, "")))))))))),;
        					    aLista[oLista:nAt,05],;
        					    aLista[oLista:nAt,06],;
        					    aLista[oLista:nAt,07],;          					             					   
       	        	            aLista[oLista:nAt,08],;
       	        	            aLista[oLista:nAt,09],;
       	        	            aLista[oLista:nAt,10],;
        	        	        aLista[oLista:nAt,11],;
      	         	            aLista[oLista:nAt,12],;
      	         	            aLista[oLista:nAt,13],;
      	         	            aLista[oLista:nAt,14],;
      	         	            aLista[oLista:nAt,15],;
      	         	            aLista[oLista:nAt,16],;      	         	           
      	         	            aLista[oLista:nAt,17],;      	         	           
      	         	            aLista[oLista:nAt,18],;      	         	           
      	          	            aLista[oLista:nAt,19]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #########################################################################
// Função pesquisa as notas fiscais para emissão da etiqueta dos correios ##
// #########################################################################
Static Function EtqNFCorreios()

   MsgRun("Aguarde! Pesquisando Notas Fiscais ...", "Pesquisando Notas Fiscais",{|| xEtqNFCorreios() })

Return(.T.)

// #########################################################################
// Função pesquisa as notas fiscais para emissão da etiqueta dos correios ##
// #########################################################################
Static Function xEtqNFCorreios()

   Local cSql := ""

   If Empty(cDataIni)
      MsgAlert("Data inicial de emissão para pesquisa não informada.")
      Return(.T.)
   Endif
      
   If Empty(cDataFim)
      MsgAlert("Data final de emissão para pesquisa não informada.")
      Return(.T.)
   Endif

   aLista := {}

   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ,"
   cSql += "       SF2.F2_DOC    ,"
   cSql += "	   SF2.F2_SERIE  ,"
   cSql += "	   SF2.F2_EMISSAO,"
   cSql += "       SF2.F2_VALBRUT,"
   cSql += "       SF2.F2_POSTAL ,"
   cSql += "       SF2.F2_ZICO   ,"
   cSql += "      (SELECT TOP(1) D2_PEDIDO FROM SD2010 WHERE D2_FILIAL = SF2.F2_FILIAL AND D2_DOC = SF2.F2_DOC AND D_E_L_E_T_ = '') AS PEDIDO,"
   cSql += "	   SF2.F2_CLIENTE,"
   cSql += " 	   SF2.F2_LOJA   ,"
   cSql += " 	   SA1.A1_NOME   ,"
   cSql += "       SA1.A1_END    ,"
   cSql += " 	   SA1.A1_MUN    ,"
   cSql += "	   SA1.A1_EST    ,"
   cSql += "	   SF2.F2_VEND1  ,"
   cSql += "      (SELECT A3_NOME  FROM " + RetSqlName("SA3") + " WHERE A3_COD    = SF2.F2_VEND1  AND D_E_L_E_T_ = '') AS VENDEDOR"
   cSql += "  FROM " + RetSqlName("SF2") + " SF2, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SF2.F2_FILIAL   = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)" + chr(13) 
   cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)" + chr(13) 
   cSql += "   AND SF2.F2_TRANSP   = '000008'"
   cSql += "   AND SF2.D_E_L_E_T_  = ''"

   If Empty(Alltrim(cNota))
   Else
      cSql += " AND SF2.F2_DOC = '" + Alltrim(cNota) + "'"
   Endif
      
   If Empty(Alltrim(cSerie))
   Else
      cSql += " AND SF2.F2_SERIE = '" + Alltrim(cSerie) + "'"
   Endif

   Do Case
      Case Substr(cComboBx2,01,01) == "1"
           cSql += " AND SF2.F2_ZICO = ' '"
            
      Case Substr(cComboBx2,01,01) == "2"
           cSql += " AND SF2.F2_ZICO = 'X'"

   EndCase

   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE"
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_  = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   T_NOTAS->( DbGoTop() )
   
   WHILE !T_NOTAS->( EOF() )

      kEmissao    := Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" +Substr(T_NOTAS->F2_EMISSAO,01,04)
      kValorBruto := Transform(T_NOTAS->F2_VALBRUT, "@E 9999999.99")

      // #################################################### 
      // Pesquisa o tipo de Serviço ECT do Pedido de Venda ##
      // ####################################################
      If Select("T_SERVICO") > 0
         T_SERVICO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C5_TSRV ,"
      cSql += "       C5_PESOL,"
      cSql += "       C5_ZEND  "
      cSql += "  FROM " + RetSqlName("SC5")
      cSql += " WHERE C5_FILIAL  = '" + Alltrim(T_NOTAS->F2_FILIAL) + "'"
      cSql += "   AND C5_NUM     = '" + Alltrim(T_NOTAS->PEDIDO)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
                                                                 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICO", .T., .T. )

      kServico := IIF(T_SERVICO->( EOF() ), "", T_SERVICO->C5_TSRV)      
      kPesoLiq := IIF(T_SERVICO->( EOF() ), Transform(0,"@E 9999999.99"), Transform(T_SERVICO->C5_PESOL, "@E 9999999.99"))      

      // #####################################################################################
      // Trata a legenda quando o endereço do cadastro for diferente do endereço de entrega ##
      // #####################################################################################
      If Empty(Alltrim(T_SERVICO->C5_ZEND))
         kLegEnd := "1"      
      Else
         If Alltrim(upper(T_NOTAS->A1_END)) == Alltrim(upper(T_SERVICO->C5_ZEND))
            kLegEnd := "2"
         Else
            kLegEnd := "8"         
         Endif   
      Endif   

      // ##################################################
      // Trata a legenda se a a etiqueta já foi impressa ##
      // ##################################################
      kLegImp := IIF(T_NOTAS->F2_ZICO == "X", "2", "8")

      // #########################
      // Carrega o array aLista ##
      // #########################
      aAdd( aLista, { .F.                ,; // 01
                      kLegImp            ,; // 02
                      " "                ,; // 03
                      kLegEnd            ,; // 04
                      T_NOTAS->F2_DOC    ,; // 05
                      T_NOTAS->F2_SERIE  ,; // 06
                      kEmissao           ,; // 07
                      kValorBruto        ,; // 08
                      T_NOTAS->PEDIDO    ,; // 09
                      kServico           ,; // 10
                      T_NOTAS->F2_CLIENTE,; // 11
                      T_NOTAS->F2_LOJA   ,; // 12
                      T_NOTAS->A1_NOME   ,; // 13
                      T_NOTAS->A1_MUN    ,; // 14
                      T_NOTAS->A1_EST    ,; // 15
                      T_NOTAS->F2_VEND1  ,; // 16
                      T_NOTAS->VENDEDOR  ,; // 17
                      T_NOTAS->F2_POSTAL ,; // 18
                      kPesoLiq           }) // 19

      T_NOTAS->( DbSkip() )                      
      
   ENDDO   
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "0", "", "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif   

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                             If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                             If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,02] == "9", oPink     ,;
                             If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
                                aLista[oLista:nAt,03]                   ,;
                             If(aLista[oLista:nAt,04] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,04] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,04] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,04] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,04] == "5", oAzul     ,;                         
                             If(aLista[oLista:nAt,04] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,04] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,04] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,04] == "9", oPink     ,;
                             If(aLista[oLista:nAt,04] == "4", oEncerra, "")))))))))),;
        					   aLista[oLista:nAt,05],;
        					   aLista[oLista:nAt,06],;
        					   aLista[oLista:nAt,07],;          					             					   
       	        	           aLista[oLista:nAt,08],;
       	        	           aLista[oLista:nAt,09],;
       	        	           aLista[oLista:nAt,10],;
        	        	       aLista[oLista:nAt,11],;
      	         	           aLista[oLista:nAt,12],;
      	         	           aLista[oLista:nAt,13],;
      	         	           aLista[oLista:nAt,14],;
      	         	           aLista[oLista:nAt,15],;
      	         	           aLista[oLista:nAt,16],;      	         	           
      	         	           aLista[oLista:nAt,17],;      	         	           
      	         	           aLista[oLista:nAt,18],;      	         	           
      	          	           aLista[oLista:nAt,19]}}

Return(.T.)   

// #################################################################
// Função que marca/desmarca os registros conforme botão acionado ##
// #################################################################
Static Function MMDDBBMM(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar    
               
Return(.T.)

// ####################################################
// Função que realiza a importação do arqiovp de PLP ##
// ####################################################
Static Function ImpCodPLP()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aFilialPLP := U_AUTOM539(2,cEmpAnt)
   Private cDataImp   := Ctod("  /  /    ")
   Private cCaminho   := Space(250)

   Private cComboBx105
   Private oGet1
   Private oGet2

   Private oDlgImp

   DEFINE MSDIALOG oDlgImp TITLE "Importação Arquivo Retorno dos Correios" FROM C(178),C(181) TO C(422),C(575) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgImp

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(190),C(001) PIXEL OF oDlgImp
   @ C(100),C(002) GET oMemo2 Var cMemo2 MEMO Size C(190),C(001) PIXEL OF oDlgImp

   @ C(033),C(005) Say "Arquivo de importação ref. a Filial"             Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgImp
   @ C(055),C(005) Say "Arquivo ref. ao dia de expedição de mercadorias" Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlgImp
   @ C(077),C(005) Say "Arquivo a ser importado"                         Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgImp
   
   @ C(043),C(005) ComboBox cComboBx105 Items aFilialPLP Size C(188),C(010)                              PIXEL OF oDlgImp
   @ C(065),C(005) MsGet    oGet1       Var   cDataImp   Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgImp
   @ C(086),C(005) MsGet    oGet2       Var   cCaminho   Size C(175),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgImp When lChumba

   @ C(086),C(181) Button "..."      Size C(012),C(009) PIXEL OF oDlgImp ACTION( BUSCACPLP() )
   @ C(105),C(059) Button "Importar" Size C(037),C(012) PIXEL OF oDlgImp ACTION( ImpArqExp() )
   @ C(105),C(099) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgImp ACTION( oDlgImp:End() )

   ACTIVATE MSDIALOG oDlgImp CENTERED 

Return(.T.)

// ###############################################
// Função que carrega o arquivo a ser importado ##
// ###############################################
Static Function BUSCACPLP()

   cCaminho := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return(.T.)

// #########################################################################
// Função que imnporta o arquivo de expedição de mercadorias dos correios ##
// #########################################################################
Static Function ImpArqExp()

   Local aCorreios := {}

   If cDataImp = Ctod("  /  /    ")
      MsgAlert("Data ref. ao dia de expedição das mercadorias não informada. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cCaminho))
      MsgAlert("Nome do arquivo a ser importado não selecionado. Verifiqeu!")
      Return(.T.)
   Endif
      

   // ####################################################
   // Abre o arquivo selecionado para pesquisa de dados ##
   // ####################################################
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo a ser importado. Tente novamente!")
      FCLOSE(nHandle)
      Return(.T.)
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
   
   cString := xBuffer

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(nHandle)

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(cCaminho)

   // #######################################
   // Separa os campos e os grava no array ##
   // #######################################
   aCorreios := {}

   For nContar = 1 to U_P_OCCURS(cString, CHR(10), 1)

       cConteudo := U_P_CORTA(cString, CHR(10), nContar) + ";"
       
       If Substr(cConteudo,01,02) == "nf"
          Loop
       Endif   

       // ###############################################
       // Separa os campos para carrega o array aLista ##
       // ###############################################
       kkNota    := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 1))),6) + "   "
       kkServico := U_P_CORTA(cConteudo, ";", 2)
       kkPlp     := U_P_CORTA(cConteudo, ";", 3)

       // ##################################
       // Prepara a série a ser utilizada ##
       // ##################################
       Do Case
          Case cEmpAnt == "01"
               Do Case
                  Case Substr(cComboBx105,01,02) == "01"
                       kkSerie := "1  "
                  Case Substr(cComboBx105,01,02) == "02"
                       kkSerie := "2  "
                  Case Substr(cComboBx105,01,02) == "03"
                       kkSerie := "3  "
                  Case Substr(cComboBx105,01,02) == "04"
                       kkSerie := "4  "
                  Case Substr(cComboBx105,01,02) == "05"
                       kkSerie := "5  "
                  Case Substr(cComboBx105,01,02) == "06"
                       kkSerie := "6  "
                  Case Substr(cComboBx105,01,02) == "07"
                       kkSerie := "7  "
               EndCase        
          Case cEmpAnt == "02"
               kkSerie := "1  "
          Case cEmpAnt == "03"
               kkSerie := "1  "
          Case cEmpAnt == "04"
               kkSerie := "1  "
       EndCase                       

       // ###############################################################
       // Atualiza os campos na Tabela F2 - Cabeçalho de Notas Fiscais ##
       // ###############################################################
	   DbSelectArea("SF2")
	   DbSetOrder(1)
	   If DbSeek( Substr(cComboBx105,01,02) + kkNota + kkSerie )
    	  RecLock("SF2",.F.)
          F2_HREXPED := "16:00:00"
	      F2_CONHECI := "EXPEDIDO NO DIA " + Dtoc(cDataImp) + " - CORREIOS"
          F2_POSTAL  := kkPlp
	      MsUnlock()
	   Endif
	
       // #####################
       // Atualiza os status ##
       // #####################
	   dbSelectArea("SD2")
	   dbSetOrder(3)
	   If dbSeek( Substr(cComboBx105,01,02) + kkNota + kkSerie )

		  While !SD2->( Eof() ) .And. Substr(cComboBx105,01,02) == SD2->D2_FILIAL .And. SD2->D2_DOC == kkNota .And. SD2->D2_SERIE == kkSerie
			
		     dbSelectArea("SC6")
			 dbSetOrder(1)
			 If dbSeek( Substr(cComboBx105,01,02) + SD2->D2_PEDIDO + SD2->D2_ITEMPV )
				RecLock("SC6",.F.)
				C6_STATUS := "12" // Expedido
				U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "12", "AUTOM616") // Gravo o log de atualização de status na tabela ZZ0
				MsUnLock()
			 EndIf

			 SD2->( dbSkip() )

	      Enddo

	   EndIf

   Next nContar

   MsgAlert("Arquivo cos Correios importado.")

   oDlgImp:End() 

Return(.T.)

// ###########################################################################
// Função que imprime as etiquetas do carreio para os registro selecionados ##
// ###########################################################################
Static Function ImpEtqCorreios()

   Local nContar    := 0
   Local lMarcados  := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private aPortas   := {"LPT1","LPT2","COM1","COM2","COM3","COM4","COM5","COM6"}
   Private cPorta

   Private oDlgPrn
   
   // ######################################################################
   // Verifica se houve marcação de pelo menos um registro para impressão ##
   // ######################################################################
   lMarcados  := .F.   
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.                                                                
          lMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Nenhum registro foi indicado para impressão. Verifique!")
      Return(.T.)
   Endif                

   
   DEFINE MSDIALOG oDlgPrn TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(342),C(480) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgPrn

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(142),C(001) PIXEL OF oDlgPrn

   @ C(040),C(005) Say "Portas de Impressão" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgPrn

   @ C(049),C(005) ComboBox cPorta Items aPortas Size C(141),C(010) PIXEL OF oDlgPrn

   @ C(065),C(037) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgPrn ACTION( ImpEtqCor(0) )
   @ C(065),C(075) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPrn ACTION( oDlgPrn:End() )

   ACTIVATE MSDIALOG oDlgPrn CENTERED 

Return(.T.)

// ##################################
// Função que imprime as etiquetas ##
// ##################################
Static Function ImpEtqCor(kTipo)

   Local nContar := 0
   Local cString := ""

   If kTipo == 0
   Else

      If Empty(Alltrim(cCaminho))
         MsgAlert("Caminho onde o arquivo de etiquetas será gerado não informado. Verifique!")
         Return(.T.)
      Endif
         
      If Empty(Alltrim(cArquivo))
         MsgAlert("Nome do arquivo de gravação das etiquetas n]ao informado. Verifique!")
         Return(.T.)
      Endif

      oDlgCSV:End()

   Endif

   cString := ""

   For nContar = 1 to Len(aLista)
   
       If aLista[nContar,01] == .F.
          Loop
       Endif   
   
       If kTipo == 0
          MSCBPRINTER("S600",cPorta)
          MSCBCHKSTATUS(.F.)
          MSCBBEGIN(2,6,) 

          MSCBWRITE("CT~~CD,~CC^~CT~" + chr(13))
          MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ" + chr(13))
          MSCBWRITE("^XA" + chr(13))
          MSCBWRITE("^MMT" + chr(13))
          MSCBWRITE("^PW559" + chr(13))
          MSCBWRITE("^LL0839" + chr(13))
          MSCBWRITE("^LS0" + chr(13))

       Else

          cString += 'MSCBPRINTER("S600","LPT1")' + chr(13) + chr(10)
          cString += 'MSCBCHKSTATUS(.F.)' + chr(13) + chr(10)
          cString += 'MSCBBEGIN(2,6,)' + chr(13) + chr(10)
          cString += 'MSCBWRITE("CT~~CD,~CC^~CT~ + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR6,6~SD15^JUS^LRN^CI0^XZ + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^XA + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^MMT + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^PW559 + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^LL0839 + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^LS0 + chr(13))' + chr(13) + chr(10)

       Endif   

       // ##############################
       // Documentação, Peso e Volume ##
       // ##############################
       If kTipo == 0

          MSCBWRITE("^FT99,406^A0B,23,24^FH\^FDNF:^FS" + chr(13))
          MSCBWRITE("^FT163,405^A0B,23,24^FH\^FDPEDIDO:^FS" + chr(13))
          MSCBWRITE("^FT162,240^A0B,23,24^FH\^FDVOLUME:^FS" + chr(13))
          MSCBWRITE("^FT100,239^A0B,23,24^FH\^FDPESO:^FS" + chr(13))
       
          MSCBWRITE("^FT130,406^A0B,34,33^FH\^FD" + aLista[nContar,05] + "^FS" + chr(13))
          MSCBWRITE("^FT131,239^A0B,34,33^FH\^FD" + aLista[Ncontar,19] + "^FS" + chr(13))
          MSCBWRITE("^FT193,238^A0B,34,33^FH\^FD" + "1"                + "^FS" + chr(13))
          MSCBWRITE("^FT194,405^A0B,34,33^FH\^FD" + aLista[Ncontar,09] + "^FS" + chr(13))

       Else

          cString += 'MSCBWRITE("^FT99,406^A0B,23,24^FH\^FDNF:^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT163,405^A0B,23,24^FH\^FDPEDIDO:^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT162,240^A0B,23,24^FH\^FDVOLUME:^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT100,239^A0B,23,24^FH\^FDPESO:^FS" + chr(13))' + chr(13) + chr(10)
       
          cString += 'MSCBWRITE("^FT130,406^A0B,34,33^FH\^FD"' + aLista[nContar,05] + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT131,239^A0B,34,33^FH\^FD"' + aLista[Ncontar,19] + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT193,238^A0B,34,33^FH\^FD"' + "1"                + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT194,405^A0B,34,33^FH\^FD"' + aLista[Ncontar,09] + '"^FS" + chr(13))' + chr(13) + chr(10)

       Endif

       // ##################
       // Valor Declarado ##
       // ##################
       If kTipo == 0

          If Alltrim(aLista[nContar,03]) == "X"
             MSCBWRITE("^FT190,808^A0B,20,19^FH\^FD" + STRZERO(VAL(Strtran(aLista[nContar,08], ",",".")),12,02) + "^FS" + chr(13))
          Endif   

       Else

          If Alltrim(aLista[nContar,03]) == "X"
             cString += 'MSCBWRITE("^FT190,808^A0B,20,19^FH\^FD"' + STRZERO(VAL(Strtran(aLista[nContar,08], ",",".")),12,02) + '"^FS" + chr(13))' + chr(13) + chr(10)
          Endif   

       Endif   
          
       // #####################
       // Site da Automatech ##
       // #####################
       If kTipo == 0
   
          MSCBWRITE("^FT542,536^A0B,23,24^FH\^FDwww.automatech.com.br^FS" + chr(13))

       Else

          cString += 'MSCBWRITE("^FT542,536^A0B,23,24^FH\^FDwww.automatech.com.br^FS" + chr(13))' + chr(13) + chr(10)

       Endif       
       
       // ############
       // Remetente ##
       // ############
       dbSelectArea("SM0")
       SM0->( DbSeek( cEmpAnt + Substr(cComboBx1,01,02) ) )

       Xcep := Substr(SM0->M0_CEPENT,01,02) + "." + Substr(SM0->M0_CEPENT,03,03) + "." + Substr(SM0->M0_CEPENT,06,03)

       If kTipo == 0

          MSCBWRITE("^FT400,808^A0B,17,16^FH\^FDREMETENTE:^FS" + chr(13))
          MSCBWRITE("^FT430,801^A0B,23,24^FH\^FD" + SM0->M0_NOMECOM + "^FS" + chr(13))
          MSCBWRITE("^FT457,800^A0B,23,24^FH\^FD" + SM0->M0_ENDENT  + "^FS" + chr(13))
          MSCBWRITE("^FT488,798^A0B,23,24^FH\^FD" + SM0->M0_BAIRENT + "^FS" + chr(13))
          MSCBWRITE("^FT517,798^A0B,23,24^FH\^FD" + SM0->M0_CIDENT  + "^FS" + chr(13))
          MSCBWRITE("^FT486,216^A0B,23,24^FH\^FD" + Xcep            + "^FS" + chr(13))                     
          MSCBWRITE("^FT515,216^A0B,23,24^FH\^FD" + SM0->M0_ESTENT  + "^FS" + chr(13))

       Else   

          cString += 'MSCBWRITE("^FT400,808^A0B,17,16^FH\^FDREMETENTE:^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT430,801^A0B,23,24^FH\^FD"' + SM0->M0_NOMECOM + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT457,800^A0B,23,24^FH\^FD"' + SM0->M0_ENDENT  + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT488,798^A0B,23,24^FH\^FD"' + SM0->M0_BAIRENT + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT517,798^A0B,23,24^FH\^FD"' + SM0->M0_CIDENT  + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT486,216^A0B,23,24^FH\^FD"' + Xcep            + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT515,216^A0B,23,24^FH\^FD"' + SM0->M0_ESTENT  + '"^FS" + chr(13))' + chr(13) + chr(10)

       Endif

       // ###############
       // Destinatário ##
       // ###############
       If Select("T_ENDERECO") > 0
          T_ENDERECO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT C5_ZEND," 
       cSql += "       C5_ZCOM,"
       cSql += "       C5_ZBAI,"
       cSql += "       C5_ZCID,"
       cSql += "       C5_ZCEP,"
       cSql += "       C5_ZEST "
       cSql += "  FROM " + RetSqlName("SC5")
       cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02) ) + "'"
       cSql += "   AND C5_NUM     = '" + Alltrim(aLista[nContar,09])       + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
          
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

       If T_ENDERECO->( EOF() )
          kNome        := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_NOME"   )
          kEndereco    := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_END"    )
          kComplemento := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_COMPLEM")
          kBairro      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_BAIRRO" )
          kCidade      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_MUN"    )
          kCep         := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_CEP"    )
          kEstado      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_EST"    )
          kCEP         := Substr(kCep,01,02) + "." + Substr(kCep,03,03) + "-" + Substr(kCep,06,03)
       Else
          kNome        := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_NOME"  )
          kEndereco    := T_ENDERECO->C5_ZEND
          kComplemento := T_ENDERECO->C5_ZCOM
          kBairro      := T_ENDERECO->C5_ZBAI
          kCidade      := T_ENDERECO->C5_ZCID
          kCep         := T_ENDERECO->C5_ZCEP
          kEstado      := T_ENDERECO->C5_ZEST
          kCEP         := Substr(kCep,01,02) + "." + Substr(kCep,03,03) + "-" + Substr(kCep,06,03)
    
          If Empty(Alltrim(kEndereco) + Alltrim(kBairro) + Alltrim(kCidade) + Alltrim(kEstado))
             kEndereco    := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_END"    )
             kComplemento := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_COMPLEM")
             kBairro      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_BAIRRO" )
             kCidade      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_MUN"    )
             kCep         := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_CEP"    )
             kEstado      := Posicione("SA1", 1, xFilial("SA1") + aLista[ncontar,11] + aLista[nContar,12], "A1_EST"    )
             kCEP         := Substr(kCep,01,02) + "." + Substr(kCep,03,03) + "-" + Substr(kCep,06,03)
          Endif

       Endif          

       If kTipo == 0
   
          MSCBWRITE("^FT235,808^A0B,17,16^FH\^FDDESTINAT\B5RIO:^FS" + chr(13))
          MSCBWRITE("^FT270,808^A0B,28,28^FH\^FD" + kNome     + "^FS" + chr(13))
          MSCBWRITE("^FT297,808^A0B,28,28^FH\^FD" + Alltrim(kEndereco) + " " + Alltrim(kComplemento) + "^FS" + chr(13))
          MSCBWRITE("^FT328,808^A0B,28,28^FH\^FD" + kBairro   + "^FS" + chr(13))
          MSCBWRITE("^FT357,808^A0B,28,28^FH\^FD" + kCidade   + "^FS" + chr(13))
          MSCBWRITE("^FT326,223^A0B,28,28^FH\^FD" + kCEP      + "^FS" + chr(13))
          MSCBWRITE("^FT355,223^A0B,28,28^FH\^FD" + kEstado   + "^FS" + chr(13))
      
       Else

          cString += 'MSCBWRITE("^FT235,808^A0B,17,16^FH\^FDDESTINAT\B5RIO:^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT270,808^A0B,28,28^FH\^FD"' + kNome     + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT297,808^A0B,28,28^FH\^FD"' + Alltrim(kEndereco) + " " + Alltrim(kComplemento) + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT328,808^A0B,28,28^FH\^FD"' + kBairro   + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT357,808^A0B,28,28^FH\^FD"' + kCidade   + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT326,223^A0B,28,28^FH\^FD"' + kCEP      + '"^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^FT355,223^A0B,28,28^FH\^FD"' + kEstado   + '"^FS" + chr(13))' + chr(13) + chr(10)

       Endif   

       // ##################
       // Tipo de Serviço ##
       // ##################
       If kTipo == 0

          MSCBWRITE("^FT92,808^A0B,23,24^FH\^FDSERVI\80O:^FS" + chr(13))
   
          Do Case
             Case U_P_OCCURS(aLista[nContar,10], "PAC", 1) == 1
                  MSCBWRITE("^FT162,808^A0B,45,45^FH\^FDPAC^FS" + chr(13))
             Case U_P_OCCURS(aLista[nContar,10], "SEDEX", 1) == 1
                  MSCBWRITE("^FT162,808^A0B,45,45^FH\^FDSEDEX^FS" + chr(13))
          EndCase

       Else
          
          cString += 'MSCBWRITE("^FT92,808^A0B,23,24^FH\^FDSERVI\80O:^FS" + chr(13))' + chr(13) + chr(10)

          Do Case
             Case U_P_OCCURS(aLista[nContar,10], "PAC", 1) == 1
                  cString += 'MSCBWRITE("^FT162,808^A0B,45,45^FH\^FDPAC^FS" + chr(13))' + chr(13)  + chr(10)
             Case U_P_OCCURS(aLista[nContar,10], "SEDEX", 1) == 1
                  cString += 'MSCBWRITE("^FT162,808^A0B,45,45^FH\^FDSEDEX^FS" + chr(13))' + chr(13) + chr(10)
          EndCase

       Endif

       // ########################
       // Cabeçalho da Etiqueta ##
       // ########################
       If kTipo == 0
          MSCBWRITE("^FT54,703^A0B,34,33^FH\^FDETIQUETA DE CORREIOS - AUTOMATECH^FS" + chr(13))
       Else
          cString += 'MSCBWRITE("^FT54,703^A0B,34,33^FH\^FDETIQUETA DE CORREIOS - AUTOMATECH^FS" + chr(13))' + chr(13) + chr(10)
       Endif   
       
       // ##########################
       // Finalização da Etiqueta ##
       // ##########################
       If kTipo == 0
          MSCBWRITE("^FO202,30^GB0,783,8^FS" + chr(13))
          MSCBWRITE("^PQ1,0,1,Y^XZ" + chr(13))
          MSCBEND()
          MSCBCLOSEPRINTER()
       Else
          cString += 'MSCBWRITE("^FO202,30^GB0,783,8^FS" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBWRITE("^PQ1,0,1,Y^XZ" + chr(13))' + chr(13) + chr(10)
          cString += 'MSCBEND()' + chr(13) + chr(10)
          cString += 'MSCBCLOSEPRINTER()' + chr(13) + chr(10)
       Endif   
       
       // ##########################################################
       // Atualiza o campo que indica que a etiqueta foi impressa ##
       // ##########################################################
       If kTipo == 0

         cSql := ""
         cSql := "UPDATE " + RetSqlName("SF2")
         cSql += "   SET"
         cSql += "   F2_ZICO        = 'X'"
         cSql += " WHERE F2_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
         cSql += "   AND F2_CLIENTE = '" + Alltrim(aLista[nContar,11])      + "'"
         cSql += "   AND F2_LOJA    = '" + Alltrim(aLista[nContar,12])      + "'"
         cSql += "   AND F2_DOC     = '" + Alltrim(aLista[nContar,05])      + "'"
         cSql += "   AND F2_SERIE   = '" + Alltrim(aLista[nContar,06])      + "'"
       
         lResult := TCSQLEXEC(cSql)

      Endif

   Next nContar    

   If kTipo == 1

      If File(Alltrim(cCaminho) + Alltrim(cArquivo))
      
         If (MsgYesNo("Arquivo já existe na pasta selecionada. Deseja sobrescrever o arquivo?","Atenção!"))

            nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
            fWrite (nHdl, cString ) 
            fClose(nHdl)
         
            MsgAlert("Arquivo gerado com sucesso.")
         
         Endif
         
      Else
         
         nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
         fWrite (nHdl, cString ) 
         fClose(nHdl)

         MsgAlert("Arquivo gerado com sucesso.")

      Endif            
         
   Endif   

Return(.T.)

// ################################################################
// Função que solicita onde o arquivo das etiquetas será gravado ##
// ################################################################
Static Function xGravaEtq()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private cArquivo := Space(060)

   Private oGet1
   Private oGet2

   Private oDlgCSV

   DEFINE MSDIALOG oDlgCSV TITLE "Etiquetas em Disco" FROM C(178),C(181) TO C(338),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgCSV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(172),C(001) PIXEL OF oDlgCSV

   @ C(033),C(005) Say "Informe o caminho a ser salvo o arquivo de Etiquetas" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV
   @ C(056),C(005) Say "Nome do arquivo a ser salvo"                          Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV

   @ C(043),C(005) MsGet oGet1 Var cCaminho Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV When lChumba
   @ C(065),C(005) MsGet oGet2 Var cArquivo Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV
   
   @ C(043),C(161) Button "..."    Size C(014),C(009) PIXEL OF oDlgCSV ACTION( xCaptaEtq() )
   @ C(062),C(097) Button "Gravar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( ImpEtqCor(1) )
   @ C(062),C(137) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( oDlgCSV:End() )

   ACTIVATE MSDIALOG oDlgCSV CENTERED 

Return(.T.)

// #########################################################################
// Função que seleciona o diretório para gravação do arquivo de Etiquetas ##
// #########################################################################
Static Function xCaptaEtq()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// ############################################################
// Função que abre janela para alterar o tipo de serviço ECT ##
// ############################################################
Static Function xAltSrvECT()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aTipoECT  := {"0 - Selecione o Serviço ECT", "1 - 40010 - SEDEX", "2 - 41106 - PAC"}
   Private kkNota	 := aLista[oLista:nAt,05]
   Private kkSerie 	 := aLista[oLista:nAt,06]
   Private kkCliente := aLista[oLista:nAt,13]

   Private cComboBx11
   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgECT

   Do Case
   
      Case U_P_OCCURS(aLista[oLista:nAt,10], "SEDEX", 1) <> 0
           cComboBx11 := "1 - 40010 - SEDEX"

      Case U_P_OCCURS(aLista[oLista:nAt,10], "PAC", 1) <> 0
           cComboBx11 := "2 - 41106 - PAC"
           
      Otherwise
           cComboBx11 := "0 - Selecione o Serviço ECT"

   EndCase

   DEFINE MSDIALOG oDlgECT TITLE "Tipo Serviço ECT" FROM C(178),C(181) TO C(437),C(473) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgECT

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(141),C(001) PIXEL OF oDlgECT
   @ C(106),C(002) GET oMemo2 Var cMemo2 MEMO Size C(141),C(001) PIXEL OF oDlgECT
   
   @ C(036),C(005) Say "Nº NFiscal"          Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgECT
   @ C(036),C(043) Say "Série"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgECT
   @ C(058),C(005) Say "Cliente"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgECT
   @ C(080),C(005) Say "Tipo de Serviço ECT" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgECT
	   
   @ C(045),C(005) MsGet    oGet1      Var   kkNota    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgECT When lChumba
   @ C(045),C(045) MsGet    oGet2      Var   kkSerie   Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgECT When lChumba
   @ C(067),C(005) MsGet    oGet3      Var   kkCliente Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgECT When lChumba
   @ C(091),C(005) ComboBox cComboBx11 Items aTipoECT  Size C(137),C(010)                              PIXEL OF oDlgECT

   @ C(112),C(053) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgECT ACTION( FechaECT() )

   ACTIVATE MSDIALOG oDlgECT CENTERED 

Return(.T.)

// ##########################################################
// Função que valida e fecha a tela de tipo de serviço ECT ##
// ##########################################################
Static Function FechaECT()

   If Substr(cComboBx11,01,01) == "0"
      MsgAlert("Tipo de Serviço ECT não selecionado. Verifique!")
      Return(.T.)
   Endif

   // ####################################################################
   // Atualiza o array aLista com a nova seleção do Tipo de Serviço ECT ##
   // ####################################################################
   aLista[oLista:nAt,10] := Alltrim(Substr(cComboBx11,05))

   // ########################################################################
   // Atualiza o pedido de venda com a nova selecção do tipo de serviço ECT ##
   // ########################################################################
   DbSelectArea("SC5")
   DbSetorder(1)
   DbSeek( Substr(cComboBx1,01,02) + aLista[oLista:nAt,09] )
   Reclock("SC5",.f.)
   SC5->C5_TSRV := Alltrim(Substr(cComboBx11,05))
   MsUnlock()

   oDlgECT:End()
   
Return(.T.)   

// ##########################################################################
// Função que permite o usuário alterar o endereço do registro selecionado ##
// ##########################################################################
Static Function AltEndereco()

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kNome        := Space(60)
   Private kEndereco    := Space(40)
   Private kComplemento := Space(40)
   Private kBairro      := Space(30)
   Private kCEP         := Space(10)
   Private kCidade      := Space(30)
   Private kEstado      := Space(03)
   Private kObservacao  := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oMemo4

   Private oDlgALE

   // ##############################################
   // Pesquisa o endereço de entrega para display ##
   // ##############################################
   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_ZEND," 
   cSql += "       C5_ZCOM,"
   cSql += "       C5_ZBAI,"
   cSql += "       C5_ZCID,"
   cSql += "       C5_ZCEP,"
   cSql += "       C5_ZEST "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02) ) + "'"
   cSql += "   AND C5_NUM     = '" + Alltrim(aLista[oLista:nAt,09])       + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
          
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   If T_ENDERECO->( EOF() )
      kNome        := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_NOME"   )
      kEndereco    := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_END"    )
      kComplemento := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_COMPLEM")
      kBairro      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_BAIRRO" )
      kCidade      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_MUN"    )
      kCep         := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_CEP"    )
      kEstado      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_EST"    )
   Else
      kNome        := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_NOME"  )
      kEndereco    := T_ENDERECO->C5_ZEND
      kComplemento := T_ENDERECO->C5_ZCOM
      kBairro      := T_ENDERECO->C5_ZBAI
      kCidade      := T_ENDERECO->C5_ZCID
      kCep         := T_ENDERECO->C5_ZCEP
      kEstado      := T_ENDERECO->C5_ZEST
    
      If Empty(Alltrim(kEndereco) + Alltrim(kBairro) + Alltrim(kCidade) + Alltrim(kEstado))
         kEndereco    := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_END"    )
         kComplemento := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_COMPLEM")
         kBairro      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_BAIRRO" )
         kCidade      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_MUN"    )
         kCep         := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_CEP"    )
         kEstado      := Posicione("SA1", 1, xFilial("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_EST"    )
      Endif

   Endif          

   If Select("T_INTERNA") > 0
      T_INTERNA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), C5_OBSI)) AS OBSERVA "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL  = '" + Alltrim(Substr(cComboBx1,01,02) ) + "'"
   cSql += "   AND C5_NUM     = '" + Alltrim(aLista[oLista:nAt,09])    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_INTERNA", .T., .T. )

   kObservacao := IIF(T_INTERNA->( EOF() ), "", T_INTERNA->OBSERVA)

   // ##############################################
   // Desenha a tela para visualização dos campos ##
   // ##############################################
   DEFINE MSDIALOG oDlgALE TITLE "Endereço de Entrega" FROM C(178),C(181) TO C(518),C(845) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgALE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(326),C(001) PIXEL OF oDlgALE
   @ C(148),C(002) GET oMemo2 Var cMemo2 MEMO Size C(326),C(001) PIXEL OF oDlgALE
	   
   @ C(023),C(261) Say "ENDEREÇO DE ENTREGA"        Size C(067),C(008) COLOR CLR_RED   PIXEL OF oDlgALE
   @ C(036),C(005) Say "Cliente"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(059),C(005) Say "Endereço"                   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(081),C(005) Say "Complemento"                Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(102),C(005) Say "Bairro"                     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(124),C(005) Say "CEP"                        Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(124),C(040) Say "Cidade"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(124),C(141) Say "UF"                         Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
   @ C(036),C(160) Say "Observação Pedido de Venda" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgALE
	
   @ C(046),C(005) MsGet oGet1  Var kNome            Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE When lChumba
   @ C(068),C(005) MsGet oGet2  Var kEndereco        Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(090),C(005) MsGet oGet3  Var kComplemento     Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(112),C(005) MsGet oGet4  Var kBairro          Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(134),C(005) MsGet oGet5  Var kCEP             Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(134),C(040) MsGet oGet6  Var kCidade          Size C(097),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(134),C(141) MsGet oGet7  Var kEstado          Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgALE
   @ C(046),C(160) GET   oMemo4 Var kObservacao MEMO Size C(168),C(097)                              PIXEL OF oDlgALE

   @ C(153),C(073) Button "Captura Endereço Prinicial" Size C(075),C(012) PIXEL OF oDlgALE ACTION( xCapEndOrigi() )
   @ C(153),C(150) Button "Confirmar"                  Size C(037),C(012) PIXEL OF oDlgALE ACTION( GrvEndereco() )
   @ C(153),C(188) Button "Voltar"                     Size C(037),C(012) PIXEL OF oDlgALE ACTION( oDlgALE:End() )

   ACTIVATE MSDIALOG oDlgALE CENTERED 

Return(.T.)

// ####################################################
// Função que captura o endereço original do cliente ##
// ####################################################
Static Function xCapEndOrigi()

   kCliente	    := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_NOME"   )
   kEndereco    := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_END"    )
   kComplemento := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_COMPLEM")
   kBairro      := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_BAIRRO" )
   kCEP	        := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_CEP"    )
   kCidade	    := POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_MUN"    )
   kEstado  	:= POSICIONE("SA1", 1, XFILIAL("SA1") + aLista[oLista:nAt,11] + aLista[oLista:nAt,12], "A1_EST"    )

   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
                  
Return(.T.)

// ###########################################################
// Função que grava e fecha a janela do endereço de entrega ##
// ###########################################################
Static Function GrvEndereco()

   If Empty(Alltrim(kEndereco) + Alltrim(kBairro) + Alltrim(kCidade) + Alltrim(kEstado))
      MsgAlert("Atenção! Endereço de entrega deve ser preenchido. Verifique!")
      Return(.T.)
   Endif

   DbSelectArea("SC5")
   DbSetOrder(1)
   If DbSeek( Substr(cComboBx1,01,02) + aLista[oLista:nAt,09] )
      RecLock("SC5",.F.)
      SC5->C5_ZEND := kEndereco
      SC5->C5_ZCOM := kComplemento
      SC5->C5_ZBAI := kBairro
      SC5->C5_ZCID := kCidade
      SC5->C5_ZCEP := kCEP
      SC5->C5_ZEST := kEstado
      MsUnLock()              
   Endif

   oDlgALE:End()
   
   // ############################
   // Reatualiza o array aLista ##
   // ############################
   EtqNFCorreios()    
   
Return(.T.)   

// ##########################################################################
// Função que gera o arquivo para ser anexado o código postal pelo correio ##
// ##########################################################################
Static Function xGeraCPostal()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private cArquivo := Space(060)

   Private oGet1
   Private oGet2

   Private oDlgCSV

   DEFINE MSDIALOG oDlgCSV TITLE "Gera Arquivo Postal" FROM C(178),C(181) TO C(338),C(542) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgCSV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(172),C(001) PIXEL OF oDlgCSV

   @ C(033),C(005) Say "Informe o caminho a ser salvo o arquivo" Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV
   @ C(056),C(005) Say "Nome do arquivo a ser salvo"             Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV

   @ C(043),C(005) MsGet oGet1 Var cCaminho Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV When lChumba
   @ C(065),C(005) MsGet oGet2 Var cArquivo Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV
   
   @ C(043),C(161) Button "..."    Size C(014),C(009) PIXEL OF oDlgCSV ACTION( xCaptaPostal() )
   @ C(062),C(097) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( xGravaPostal() )
   @ C(062),C(137) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCSV ACTION( oDlgCSV:End() )

   ACTIVATE MSDIALOG oDlgCSV CENTERED 

Return(.T.)

// ################################################################
// Função que seleciona o diretório para gravação do arquivo CSV ##
// ################################################################
Static Function xCaptaPostal()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function xGravaPostal()

   Local nContar   := 0
   Local cString   := ""
   Local lPrimeiro := .T.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo CSV não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cArquivo))
      MsgAlert("Nome do arquivo para gravação não informado.")
      Return(.T.)
   Endif

   If U_P_OCCURS(cArquivo, ".CSV", 1) == 0
      cArquivo := Alltrim(cArquivo) + ".CSV"
   Endif   

   cString := ""

   For nContar = 1 to Len(aBrowse)
      
       If lPrimeiro == .T.
          cString += 'EMPRESA'                + ";" + ;
                     'FILIAL'                 + ";" + ;
                     'ULTIMA ENTRADA'         + ";" + ;
                     'DIAS'                   + ";" + ;
                     'PRODUTO'                + ";" + ;
                     'PARTNUMBER'             + ";" + ;
                     'GRUPO'                  + ";" + ;
                     'DESCRICAO DOS PRODUTOS' + ";" + ;
                     'SALDO'                  + ";" + ;
                     'CUSTO MEDIO'            + chr(13)
          lPrimeiro := .F.
       Endif
       
       cString += aBrowse[nContar,01]           + ";" + ;
                  aBrowse[nContar,02]           + ";" + ;
                  aBrowse[nContar,03]           + ";" + ;
                  Alltrim(aBrowse[nContar,04])  + ";" + ;
                  Alltrim(aBrowse[nContar,05])  + ";" + ;
                  Alltrim(aBrowse[nContar,06] ) + ";" + ;
                  aBrowse[nContar,07]           + ";" + ;
                  Alltrim(aBrowse[nContar,08] ) + ";" + ;
                  str(aBrowse[nContar,09] )     + ";" + ;
                  Str(aBrowse[nContar,10] )     + chr(13)

   Next nContar

   If File(Alltrim(cCaminho) + Alltrim(cArquivo))
      
      If (MsgYesNo("Arquivo já existe na pasta selecionada. Deseja sobrescrever o arquivo?","Atenção!"))

         nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
         fWrite (nHdl, cString ) 
         fClose(nHdl)
         
         MsgAlert("Arquivo gerado com sucesso.")
         
      Endif
         
   Else
         
      nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      MsgAlert("Arquivo gerado com sucesso.")

   Endif            

   oDlgCSV:End()
   
Return(.T.)