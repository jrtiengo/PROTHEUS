#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR30.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 18/10/2011                                                          ##
// Objetivo..: Rastreabilidade de Nº de Série                                      ##
// ##################################################################################

User Function AUTOMR30()   
 
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private aEmpresas   := U_AUTOM539(1, "")
   Private aFiliais	   := U_AUTOM539(2, cEmpAnt)
   Private aStatus     := {"1 - OS Abertas", "2 - Todos Status"}
   Private aPesquisa   := {"EXATA", "INICIANDO", "CONTENDO"}
   Private cSerie      := Space(20)
   Private cCliente    := Space(06)
   Private cLojaCli    := Space(03)
   Private cNomeCli    := Space(60)
   Private lTodasLojas := .F.
   Private lEmpresas   := .F.

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2
   Private oGet3   
   Private oGet4   

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

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Rastreabilidade por Nº de Série" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(023) PIXEL NOBORDER OF oDlg
   @ C(210),C(005) Jpeg FILE "br_branco.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(210),C(107) Jpeg FILE "br_azul.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(005),C(181) Say "Empresas"                           Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(181) Say "Filiais"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(005) Say "Nº de Série"                        Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(079) Say "Tipo de Pesquisa"                   Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(181) Say "Cliente"                            Size C(079),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(210),C(017) Say "Nº de Série sem vínculo a contrato" Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(210),C(121) Say "Nº de Série vinculado a contrato"   Size C(079),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(330) Say "Status"                             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(330) CheckBox oCheckBox2 Var   lEmpresas   Prompt "Todas as Empresas/Filiais" Size C(073),C(008)           PIXEL OF oDlg
   @ C(017),C(349) ComboBox cComboBx4  Items aStatus     Size C(072),C(010)                                              PIXEL OF oDlg
   @ C(004),C(210) ComboBox cComboBx2  Items aEmpresas   Size C(100),C(010)                                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(017),C(210) ComboBox cComboBx3  Items aFiliais    Size C(100),C(010)                                              PIXEL OF oDlg
   @ C(043),C(005) MsGet    oGet1      Var   cSerie      Size C(068),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlg
   @ C(043),C(079) ComboBox cComboBx1  Items aPesquisa   Size C(098),C(010)                                              PIXEL OF oDlg
   @ C(033),C(233) CheckBox oCheckBox1 Var   lTodasLojas Prompt "Pesquisar todas as lojas do Cliente" Size C(093),C(008) PIXEL OF oDlg
   @ C(043),C(181) MsGet    oGet2      Var   cCliente    Size C(026),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlg F3("SA1") 
   @ C(043),C(211) MsGet    oGet3      Var   cLojaCli    Size C(019),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlg VALID( cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLojacli, "A1_NOME") )
   @ C(043),C(233) MsGet    oGet4      Var   cNomeCli    Size C(179),C(009) COLOR CLR_BLACK Picture "@!"                 PIXEL OF oDlg When lChumba

   @ C(040),C(419) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( CARREGAGRID() ) When !Empty(cSerie) .Or. !Empty(cCliente)
   @ C(040),C(461) Button "Detalhes"  Size C(037),C(012) PIXEL OF oDlg ACTION( MostraDtl() )   When !Empty(Alltrim(aLista[01,03]))
   @ C(210),C(461) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   @ 078,005 LISTBOX oLista FIELDS HEADER "Leg"                    ,; // 01
                                          "Nº Contrato"            ,; // 02
                                          "Operação"               ,; // 03
                                          "Data"                   ,; // 04
                                          "Nº OS"                  ,; // 05
                                          "Nota Fiscal"            ,; // 06
                                          "Série"                  ,; // 07
                                          "Código"                 ,; // 08
                                          "Loja"                   ,; // 09
                                          "Fornecedor/Cliente"     ,; // 10
                                          "Nº de Série"            ,; // 11
                                          "Produto"                ,; // 12
                                          "Descrição dos Produtos" ,; // 13 
                                          "Empresa"                ,; // 14
                                          "Filial"                  ; // 15
                                          PIXEL SIZE 633,187 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||     {If(aLista[oLista:nAt,01] == "0", oBranco   ,;
                            If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                            If(aLista[oLista:nAt,01] == "3", oCancel   ,;                         
                            If(aLista[oLista:nAt,01] == "1", oAmarelo  ,;                         
                            If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                            If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                            If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                            If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                            If(aLista[oLista:nAt,01] == "9", oPink     ,;
                            If(aLista[oLista:nAt,01] == "4", oEncerra, "")))))))))),;
          					   aLista[oLista:nAt,02],;
          					   aLista[oLista:nAt,03],;
          					   aLista[oLista:nAt,04],;
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
         	        	       aLista[oLista:nAt,15]}}

   oLista:bHeaderClick := {|oObj,nCol| oLista:aArray := Ordenar(nCol,oLista:aArray),oLista:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx2,01,02) )
   @ C(017),C(210) ComboBox cComboBx3  Items aFiliais    Size C(100),C(010)                                              PIXEL OF oDlg

Return(.T.)

// ############################################################################
// Função que carrega o grid com as informações do numero de serie informado ##
// ############################################################################
Static Function CARREGAGRID()

   MsgRun("Aguarde! Pesquisando (pode levar alguns instantes)", "Rastrealidade Nº Série",{|| xCARREGAGRID() })

Return(.T.)

// ############################################################################
// Função que carrega o grid com as informações do numero de serie informado ##
// ############################################################################
Static Function xCARREGAGRID()

   Local cSql      := ""

   If Empty(Alltrim(cSerie)) .And. Empty(Alltrim(cCliente))
      MsgAlert("Necessário informar Nº de série a ser ratreado ou Cliente. verifique!")
      Return .T.
   Endif

   aLista := {}

   If Select("T_SERIE") > 0
      T_SERIE->( dbCloseArea() )
   EndIf

   If lEmpresas == .F.

      cSql := ""
      cSql := "SELECT A.DB_NUMSERI, " + CHR(13)
      cSql += "       A.DB_DATA   , " + CHR(13)
      cSql += "       A.DB_DOC    , " + CHR(13)
      cSql += "       A.DB_SERIE  , " + CHR(13)
      cSql += "       A.DB_CLIFOR , " + CHR(13)
      cSql += "       A.DB_LOJA   , " + CHR(13)
      cSql += "       A.DB_TIPO   , " + CHR(13)
      cSql += "       A.DB_PRODUTO, " + CHR(13)
      cSql += "       B.B1_DESC   , " + CHR(13)
      cSql += "       B.B1_DAUX   , " + CHR(13)
      cSql += "       A.DB_ORIGEM , " + CHR(13)
      cSql += "       A.DB_FILIAL , " + CHR(13)
      cSql += "     " +  Substr(cComboBx2,01,02) + " AS EMPRESA " + CHR(13)
      cSql += "  FROM SDB" + Substr(cComboBx2,01,02) + "0 A, " + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  " + CHR(13)
      cSql += " WHERE A.DB_PRODUTO = B.B1_COD "
      cSql += "   AND B.D_E_L_E_T_ = ''"
      cSql += "   AND A.DB_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND DB_NUMSERI = '" + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND DB_NUMSERI LIKE '" + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND DB_NUMSERI LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.DB_CLIFOR = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.DB_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      cSql += " GROUP BY A.DB_NUMSERI, A.DB_DATA, A.DB_DOC, A.DB_SERIE, A.DB_CLIFOR, A.DB_LOJA, A.DB_TIPO, A.DB_PRODUTO, B.B1_DESC, B.B1_DAUX, A.DB_ORIGEM, A.DB_FILIAL" + CHR(13)

   Else  
             
      cSql := ""
      cSql := "SELECT A.DB_NUMSERI, "   + CHR(13)
      cSql += "       A.DB_DATA   , "   + CHR(13)
      cSql += "       A.DB_DOC    , "   + CHR(13)
      cSql += "       A.DB_SERIE  , "   + CHR(13)
      cSql += "       A.DB_CLIFOR , "   + CHR(13)
      cSql += "       A.DB_LOJA   , "   + CHR(13)
      cSql += "       A.DB_TIPO   , "   + CHR(13)
      cSql += "       A.DB_PRODUTO, "   + CHR(13)
      cSql += "       B.B1_DESC   , "   + CHR(13)
      cSql += "       B.B1_DAUX   , "   + CHR(13)
      cSql += "       A.DB_ORIGEM , "   + CHR(13)
      cSql += "       A.DB_FILIAL , "   + CHR(13) 
      cSql += "       '01' AS EMPRESA " + CHR(13)
      cSql += "  FROM SDB010 A, "       + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  " + CHR(13)
      cSql += " WHERE A.DB_PRODUTO = B.B1_COD "
      cSql += "   AND B.D_E_L_E_T_ = ''"
//    cSql += "   AND A.DB_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND DB_NUMSERI = '" + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND DB_NUMSERI LIKE '" + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND DB_NUMSERI LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.DB_CLIFOR = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.DB_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      cSql += " GROUP BY A.DB_NUMSERI, A.DB_DATA, A.DB_DOC, A.DB_SERIE, A.DB_CLIFOR, A.DB_LOJA, A.DB_TIPO, A.DB_PRODUTO, B.B1_DESC, B.B1_DAUX, A.DB_ORIGEM, A.DB_FILIAL" + CHR(13)
   
      cSql += " UNION "   
   
      cSql += "SELECT A.DB_NUMSERI, "   + CHR(13)
      cSql += "       A.DB_DATA   , "   + CHR(13)
      cSql += "       A.DB_DOC    , "   + CHR(13)
      cSql += "       A.DB_SERIE  , "   + CHR(13)
      cSql += "       A.DB_CLIFOR , "   + CHR(13)
      cSql += "       A.DB_LOJA   , "   + CHR(13)
      cSql += "       A.DB_TIPO   , "   + CHR(13)
      cSql += "       A.DB_PRODUTO, "   + CHR(13)
      cSql += "       B.B1_DESC   , "   + CHR(13)
      cSql += "       B.B1_DAUX   , "   + CHR(13)
      cSql += "       A.DB_ORIGEM , "   + CHR(13)
      cSql += "       A.DB_FILIAL , "   + CHR(13) 
      cSql += "       '02' AS EMPRESA " + CHR(13)
      cSql += "  FROM SDB020 A, "       + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  " + CHR(13)
      cSql += " WHERE A.DB_PRODUTO = B.B1_COD "
      cSql += "   AND B.D_E_L_E_T_ = ''"
//    cSql += "   AND A.DB_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND DB_NUMSERI = '" + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND DB_NUMSERI LIKE '" + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND DB_NUMSERI LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.DB_CLIFOR = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.DB_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      cSql += " GROUP BY A.DB_NUMSERI, A.DB_DATA, A.DB_DOC, A.DB_SERIE, A.DB_CLIFOR, A.DB_LOJA, A.DB_TIPO, A.DB_PRODUTO, B.B1_DESC, B.B1_DAUX, A.DB_ORIGEM, A.DB_FILIAL" + CHR(13)
   
      cSql += " UNION "   
   
      cSql += "SELECT A.DB_NUMSERI, "   + CHR(13)
      cSql += "       A.DB_DATA   , "   + CHR(13)
      cSql += "       A.DB_DOC    , "   + CHR(13)
      cSql += "       A.DB_SERIE  , "   + CHR(13)
      cSql += "       A.DB_CLIFOR , "   + CHR(13)
      cSql += "       A.DB_LOJA   , "   + CHR(13)
      cSql += "       A.DB_TIPO   , "   + CHR(13)
      cSql += "       A.DB_PRODUTO, "   + CHR(13)
      cSql += "       B.B1_DESC   , "   + CHR(13)
      cSql += "       B.B1_DAUX   , "   + CHR(13)
      cSql += "       A.DB_ORIGEM , "   + CHR(13)
      cSql += "       A.DB_FILIAL , "   + CHR(13) 
      cSql += "       '03' AS EMPRESA " + CHR(13)
      cSql += "  FROM SDB030 A, "       + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  " + CHR(13)
      cSql += " WHERE A.DB_PRODUTO = B.B1_COD "
      cSql += "   AND B.D_E_L_E_T_ = ''"
//    cSql += "   AND A.DB_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND DB_NUMSERI = '" + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND DB_NUMSERI LIKE '" + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND DB_NUMSERI LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.DB_CLIFOR = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.DB_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      cSql += " GROUP BY A.DB_NUMSERI, A.DB_DATA, A.DB_DOC, A.DB_SERIE, A.DB_CLIFOR, A.DB_LOJA, A.DB_TIPO, A.DB_PRODUTO, B.B1_DESC, B.B1_DAUX, A.DB_ORIGEM, A.DB_FILIAL" + CHR(13)

      cSql += " UNION "   
   
      cSql += "SELECT A.DB_NUMSERI, "   + CHR(13)
      cSql += "       A.DB_DATA   , "   + CHR(13)
      cSql += "       A.DB_DOC    , "   + CHR(13)
      cSql += "       A.DB_SERIE  , "   + CHR(13)
      cSql += "       A.DB_CLIFOR , "   + CHR(13)
      cSql += "       A.DB_LOJA   , "   + CHR(13)
      cSql += "       A.DB_TIPO   , "   + CHR(13)
      cSql += "       A.DB_PRODUTO, "   + CHR(13)
      cSql += "       B.B1_DESC   , "   + CHR(13)
      cSql += "       B.B1_DAUX   , "   + CHR(13)
      cSql += "       A.DB_ORIGEM , "   + CHR(13)
      cSql += "       A.DB_FILIAL , "   + CHR(13) 
      cSql += "       '04' AS EMPRESA " + CHR(13)
      cSql += "  FROM SDB040 A, "       + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  " + CHR(13)
      cSql += " WHERE A.DB_PRODUTO = B.B1_COD "
      cSql += "   AND B.D_E_L_E_T_ = ''"
//    cSql += "   AND A.DB_FILIAL  = '" + Substr(cComboBx3,01,02) + "'" + CHR(13)

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND DB_NUMSERI = '" + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND DB_NUMSERI LIKE '" + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND DB_NUMSERI LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.DB_CLIFOR = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.DB_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      cSql += " GROUP BY A.DB_NUMSERI, A.DB_DATA, A.DB_DOC, A.DB_SERIE, A.DB_CLIFOR, A.DB_LOJA, A.DB_TIPO, A.DB_PRODUTO, B.B1_DESC, B.B1_DAUX, A.DB_ORIGEM, A.DB_FILIAL" + CHR(13)

   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIE", .T., .T. )

   // ########################################
   // Inicializa o Array que carrega o Grid ##
   // ########################################
   aLista := {}

   While !T_SERIE->( EOF() )

      Do Case
         Case T_SERIE->DB_ORIGEM == "SD1"
              _Operacao := "Entrada"
         Case T_SERIE->DB_ORIGEM == "SC6"
              _Operacao := "Saída"
         Otherwise
              _Operacao := "Mov.Interna"                       
      EndCase        

      _Data      := Substr(T_SERIE->DB_DATA,07,02) + "/" + Substr(T_SERIE->DB_DATA,05,02) + "/" + Substr(T_SERIE->DB_DATA,01,04)
      _Etiqueta  := ""
      _Documento := T_SERIE->DB_DOC
      _Serie     := T_SERIE->DB_SERIE
      _Codigo    := T_SERIE->DB_CLIFOR
      _Loja      := T_SERIE->DB_LOJA
      _Nserie    := T_SERIE->DB_NUMSERI
      _Produto   := Alltrim(T_SERIE->DB_PRODUTO)
      _Descricao := Alltrim(T_SERIE->B1_DESC) + " " + T_SERIE->B1_DAUX
      _Empresa   := T_SERIE->EMPRESA
      _Filial    := T_SERIE->DB_FILIAL
      _xData     := T_SERIE->DB_DATA
            
      Do Case
         Case T_SERIE->DB_ORIGEM == "SD1"
              cNome_cliente := POSICIONE("SA2",1,XFILIAL("SA2") + T_SERIE->DB_CLIFOR + T_SERIE->DB_LOJA,"A2_NOME")
         Case T_SERIE->DB_ORIGEM == "SC6"
              cNome_cliente := POSICIONE("SA1",1,XFILIAL("SA1") + T_SERIE->DB_CLIFOR + T_SERIE->DB_LOJA,"A1_NOME")
         Otherwise
              cNome_cliente := ""
      EndCase

      aAdd( aLista, { "0"          ,; // 01
                      ""           ,; // 02
                      _Operacao    ,; // 03
                      _Data        ,; // 04
                      _Etiqueta    ,; // 05
                      _Documento   ,; // 06
                      _Serie       ,; // 07
                      _Codigo      ,; // 08
                      _Loja        ,; // 09
                      cNome_cliente,; // 10
                      _Nserie      ,; // 11
                      _Produto     ,; // 12
                      _Descricao   ,; // 13
                      _Empresa     ,; // 14
                      _Filial      ,; // 15
                      _xData       }) // 16

      T_SERIE->( DbSkip() )

   Enddo

   // ###################################################################
   // Verifica se o número de serie já passou pela assistência técnica ##
   // ###################################################################
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   If lEmpresas == .T.

      cSql := ""
      cSql := "SELECT A.AB7_NUMSER, "
      cSql += "       A.AB7_NUMOS , "
      cSql += "       A.AB7_FILIAL, "
      cSql += "       A.AB7_EMISSA, "
      cSql += "       A.AB7_CODCLI, "
      cSql += "       A.AB7_LOJA  , "
      cSql += "       B.A1_NOME   , "
      cSql += "       C.AB6_ETIQUE, "
      cSql += "       A.AB7_CODPRO, "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "     " + Substr(cComboBx2,01,02) + " AS EMPRESA "
      cSql += "  FROM AB7" + Substr(cComboBx2,01,02) + "0 A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       AB6" + Substr(cComboBx2,01,02) + "0 C, "
      cSql += "       " + RetSqlName("SB1") + " D  "
      cSql += " WHERE A.AB7_NUMSER   = '" + Alltrim(cSerie)  + "'"
      cSql += "   AND A.AB7_FILIAL   = '" + Substr(cComboBx3,01,02) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.AB7_CODCLI   = B.A1_COD    "
      cSql += "   AND A.AB7_LOJA     = B.A1_LOJA   "
      cSql += "   AND A.AB7_NUMOS    = C.AB6_NUMOS "
      cSql += "   AND A.AB7_FILIAL   = C.AB6_FILIAL"
      cSql += "   AND C.D_E_L_E_T_   = ''          "  
      cSql += "   AND A.AB7_CODPRO   = D.B1_COD    "

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND A.AB7_NUMSER = '"     + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND A.AB7_NUMSER LIKE '"  + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND A.AB7_NUMSER LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.AB7_CODCLI = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.AB7_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   
   
      If Substr(cComboBx4,1,1) == "1"
         cSql += " AND C.AB6_STATUS NOT IN ('B', 'E', 'D') "
      Endif   

   Else
   
      cSql := ""
      cSql := "SELECT A.AB7_NUMSER, "
      cSql += "       A.AB7_NUMOS , "
      cSql += "       A.AB7_FILIAL, "
      cSql += "       A.AB7_EMISSA, "
      cSql += "       A.AB7_CODCLI, "
      cSql += "       A.AB7_LOJA  , "
      cSql += "       B.A1_NOME   , "
      cSql += "       C.AB6_ETIQUE, "
      cSql += "       A.AB7_CODPRO, "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       01 AS EMPRESA "
      cSql += "  FROM AB7010 A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       AB6010 C, "
      cSql += "       " + RetSqlName("SB1") + " D  "
      cSql += " WHERE A.AB7_NUMSER   = '" + Alltrim(cSerie)  + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.AB7_CODCLI   = B.A1_COD    "
      cSql += "   AND A.AB7_LOJA     = B.A1_LOJA   "
      cSql += "   AND A.AB7_NUMOS    = C.AB6_NUMOS "
      cSql += "   AND A.AB7_FILIAL   = C.AB6_FILIAL"
      cSql += "   AND C.D_E_L_E_T_   = ''          "  
      cSql += "   AND A.AB7_CODPRO   = D.B1_COD    "
      
      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND A.AB7_NUMSER = '"     + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND A.AB7_NUMSER LIKE '"  + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND A.AB7_NUMSER LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.AB7_CODCLI = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.AB7_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      If Substr(cComboBx4,1,1) == "1"
         cSql += " AND C.AB6_STATUS NOT IN ('B', 'E', 'D') "
      Endif   

      cSql += " UNION "
   
      cSql += "SELECT A.AB7_NUMSER, "
      cSql += "       A.AB7_NUMOS , "
      cSql += "       A.AB7_FILIAL, "
      cSql += "       A.AB7_EMISSA, "
      cSql += "       A.AB7_CODCLI, "
      cSql += "       A.AB7_LOJA  , "
      cSql += "       B.A1_NOME   , "
      cSql += "       C.AB6_ETIQUE, "
      cSql += "       A.AB7_CODPRO, "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       02 AS EMPRESA "
      cSql += "  FROM AB7020 A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       AB6020 C, "
      cSql += "       " + RetSqlName("SB1") + " D  "
      cSql += " WHERE A.AB7_NUMSER   = '" + Alltrim(cSerie)  + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.AB7_CODCLI   = B.A1_COD    "
      cSql += "   AND A.AB7_LOJA     = B.A1_LOJA   "
      cSql += "   AND A.AB7_NUMOS    = C.AB6_NUMOS "
      cSql += "   AND A.AB7_FILIAL   = C.AB6_FILIAL"
      cSql += "   AND C.D_E_L_E_T_   = ''          "  
      cSql += "   AND A.AB7_CODPRO   = D.B1_COD    "

      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND A.AB7_NUMSER = '"     + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND A.AB7_NUMSER LIKE '"  + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND A.AB7_NUMSER LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.AB7_CODCLI = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.AB7_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   
   
      If Substr(cComboBx4,1,1) == "1"
         cSql += " AND C.AB6_STATUS NOT IN ('B', 'E', 'D') "
      Endif   

      cSql += " UNION "
         
      cSql += "SELECT A.AB7_NUMSER, "
      cSql += "       A.AB7_NUMOS , "
      cSql += "       A.AB7_FILIAL, "
      cSql += "       A.AB7_EMISSA, "
      cSql += "       A.AB7_CODCLI, "
      cSql += "       A.AB7_LOJA  , "
      cSql += "       B.A1_NOME   , "
      cSql += "       C.AB6_ETIQUE, "
      cSql += "       A.AB7_CODPRO, "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       03 AS EMPRESA "
      cSql += "  FROM AB7030 A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       AB6030 C, "
      cSql += "       " + RetSqlName("SB1") + " D  "
      cSql += " WHERE A.AB7_NUMSER   = '" + Alltrim(cSerie)  + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.AB7_CODCLI   = B.A1_COD    "
      cSql += "   AND A.AB7_LOJA     = B.A1_LOJA   "
      cSql += "   AND A.AB7_NUMOS    = C.AB6_NUMOS "
      cSql += "   AND A.AB7_FILIAL   = C.AB6_FILIAL"
      cSql += "   AND C.D_E_L_E_T_   = ''          "  
      cSql += "   AND A.AB7_CODPRO   = D.B1_COD    "
   
      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND A.AB7_NUMSER = '"     + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND A.AB7_NUMSER LIKE '"  + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND A.AB7_NUMSER LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.AB7_CODCLI = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.AB7_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      If Substr(cComboBx4,1,1) == "1"
         cSql += " AND C.AB6_STATUS NOT IN ('B', 'E', 'D') "
      Endif   

      cSql += " UNION "
         
      cSql += "SELECT A.AB7_NUMSER, "
      cSql += "       A.AB7_NUMOS , "
      cSql += "       A.AB7_FILIAL, "
      cSql += "       A.AB7_EMISSA, "
      cSql += "       A.AB7_CODCLI, "
      cSql += "       A.AB7_LOJA  , "
      cSql += "       B.A1_NOME   , "
      cSql += "       C.AB6_ETIQUE, "
      cSql += "       A.AB7_CODPRO, "
      cSql += "       D.B1_DESC   , "
      cSql += "       D.B1_DAUX   , "
      cSql += "       04 AS EMPRESA "
      cSql += "  FROM AB7040 A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       AB6040 C, "
      cSql += "       " + RetSqlName("SB1") + " D  "
      cSql += " WHERE A.AB7_NUMSER   = '" + Alltrim(cSerie)  + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = ''          "
      cSql += "   AND A.AB7_CODCLI   = B.A1_COD    "
      cSql += "   AND A.AB7_LOJA     = B.A1_LOJA   "
      cSql += "   AND A.AB7_NUMOS    = C.AB6_NUMOS "
      cSql += "   AND A.AB7_FILIAL   = C.AB6_FILIAL"
      cSql += "   AND C.D_E_L_E_T_   = ''          "  
      cSql += "   AND A.AB7_CODPRO   = D.B1_COD    "
      
      If Empty(Alltrim(cSerie))
      Else
         Do Case
            Case cComboBx1 == "EXATA"
                 cSql += " AND A.AB7_NUMSER = '"     + Alltrim(cSerie) + "'" + CHR(13)
            Case cComboBx1 == "INICIANDO"
                 cSql += " AND A.AB7_NUMSER LIKE '"  + Alltrim(cSerie) + "%'" + CHR(13)
            Case cComboBx1 == "CONTENDO"
                 cSql += " AND A.AB7_NUMSER LIKE '%" + Alltrim(cSerie) + "%'" + CHR(13)
         EndCase           
      Endif   

      If Empty(Alltrim(cCliente))
      Else
         cSql += " AND A.AB7_CODCLI = '" + Alltrim(cCliente) + "'"
      
         If lTodasLojas == .T.
         Else
            cSql += " AND A.AB7_LOJA   = '" + Alltrim(cLojaCli) + "'"
         Endif   
      Endif   

      If Substr(cComboBx4,1,1) == "1"
         cSql += " AND C.AB6_STATUS NOT IN ('B', 'E', 'D') "
      Endif   

   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   T_CLIENTE->( DbGoTop() )

   While !T_CLIENTE->( EOF() )
   
      _Operacao  := "Técnica"
      _Data      := Substr(T_CLIENTE->AB7_EMISSA,07,02) + "/" + Substr(T_CLIENTE->AB7_EMISSA,05,02) + "/" + Substr(T_CLIENTE->AB7_EMISSA,01,04)
      _Etiqueta  := T_CLIENTE->AB6_ETIQUE
      _Documento := ""
      _Serie     := ""
      _Codigo    := T_CLIENTE->AB7_CODCLI
      _Loja      := T_CLIENTE->AB7_LOJA
      _Cliente   := T_CLIENTE->A1_NOME
      _Nserie    := T_CLIENTE->AB7_NUMSER
      _Produto   := Alltrim(T_CLIENTE->AB7_CODPRO)
      _Descricao := Alltrim(T_CLIENTE->B1_DESC) + " " + T_CLIENTE->B1_DAUX
      _Empresa   := T_CLIENTE->EMPRESA
      _Filial    := T_CLIENTE->AB7_FILIAL
      _xData     := T_CLIENTE->AB7_EMISSA

      aAdd( aLista, { "0"       ,; // 01
                      ""        ,; // 02
                      _Operacao ,; // 03
                      _Data     ,; // 04
                      _Etiqueta ,; // 05
                      _Documento,; // 06
                      _Serie    ,; // 07
                      _Codigo   ,; // 08
                      _Loja     ,; // 09
                      _Cliente  ,; // 10
                      _Nserie   ,; // 11
                      _Produto  ,; // 12
                      _Descricao,; // 13
                      _Empresa  ,; // 14
                      _Filial   ,; // 15
                      _xData    }) // 16

      T_CLIENTE->( DbSkip() )

   Enddo

   // #################################################################
   // Verifica se os nºs de séries estão vinculados a algum contrato ##
   // #################################################################
   For nContar = 1 to Len(aLista)
   
       If Select("T_SERIES") > 0
          T_SERIES->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT AA3.AA3_FILIAL,"
       cSql += "       AA3.AA3_CODCLI,"
       cSql += "       AA3.AA3_LOJA  ,"
	   cSql += "       AA3.AA3_CODPRO,"
	   cSql += "       AA3.AA3_NUMSER,"
	   cSql += "       AA3.AA3_CONTRT,"
	   cSql += "       AA3.AA3_DTINST "
       cSql += "    FROM AA3" + Substr(cComboBx2,01,02) + "0 AA3 "
       cSql += "   WHERE AA3_FILIAL     = '" + sUBSTR(CcOMBObX3,01,02)     + "'"
       cSql += "     AND AA3_CODCLI     = '" + Alltrim(aLista[nContar,08]) + "'"
       cSql += "     AND AA3_LOJA       = '" + Alltrim(aLista[nContar,09]) + "'"
       cSql += "     AND AA3_CODPRO     = '" + Alltrim(aLista[nContar,12]) + "'"
       cSql += "     AND AA3_NUMSER     = '" + Alltrim(aLista[nContar,11]) + "'"
       cSql += "     AND AA3.D_E_L_E_T_ = ''

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

       If T_SERIES->( EOF() )
          aLista[nContar,01] := "0"
          aLista[nContar,02] := ""
       Else
          If Empty(Alltrim(T_SERIES->AA3_CONTRT))
             aLista[nContar,01] := "0"
             aLista[nContar,02] := ""
          Else   
             aLista[nContar,01] := "5"
             aLista[nContar,02] := T_SERIES->AA3_CONTRT
          Endif   
       Endif

   Next nContar          

   If Len(aLista) == 0
      aAdd( aLista, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
      MsgAlert("Não existem dados a serem visualizados para este nº de série.")
      Return .T.    
   Endif

   // ################################
   // Ordena o Array para Impressão ##
   // ################################
   ASORT(aLista,,,{ | x,y | x[14] < y[14] } )

   // ####################
   // Atualiza o Browse ##
   // ####################
   oLista:SetArray( aLista )

   oLista:bLine := {||     {If(aLista[oLista:nAt,01] == "0", oBranco   ,;
                            If(aLista[oLista:nAt,01] == "2", oVerde    ,;
                            If(aLista[oLista:nAt,01] == "3", oCancel   ,;                         
                            If(aLista[oLista:nAt,01] == "1", oAmarelo  ,;                         
                            If(aLista[oLista:nAt,01] == "5", oAzul     ,;                         
                            If(aLista[oLista:nAt,01] == "6", oLaranja  ,;                         
                            If(aLista[oLista:nAt,01] == "7", oPreto    ,;                         
                            If(aLista[oLista:nAt,01] == "8", oVermelho ,;
                            If(aLista[oLista:nAt,01] == "9", oPink     ,;
                            If(aLista[oLista:nAt,01] == "4", oEncerra, "")))))))))),;
          					   aLista[oLista:nAt,02],;
          					   aLista[oLista:nAt,03],;
          					   aLista[oLista:nAt,04],;
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
         	        	       aLista[oLista:nAt,15]}}

Return .T.

// Função que abre a tela conforme o botão selecionado
Static Function ABRE_TELA( _Tipo, cComboBx2, _Codigo)

   Local aIndex   := {}
   Local cFiltro1 := "AD1_FILIAL == '" + Substr(cComboBx2,01,02) + "', AD1_NROPOR == '" + Alltrim(_Codigo) + "'"
   Local cFiltro2 := "C5_FILIAL  == '" + Substr(cComboBx2,01,02) + "', C5_NUM     == '" + Alltrim(_Codigo) + "'"
   Local cFiltro3 := "ADY_FILIAL == '" + Substr(cComboBx2,01,02) + "', ADY_PROPOS == '" + Alltrim(_Codigo) + "'"
   
   Private aRotina := {;
                      { "Pesquisar"  , ""         , 0 , 1 },;
                      { "Visualizar" , "AxVisual" , 0 , 2 },;
                      { "Incluir"    , ""         , 0 , 3 },;
                      { "Alterar"    , ""         , 0 , 4 },;
                      { "Excluir"    , ""         , 0 , 5 } ;
                      }

   //Determina a Expressão do Filtro
   Do Case
      Case _Tipo == 1
           Private bFiltraBrw := { || FilBrowse( "AD1" , @aIndex , @cFiltro1 ) } 
           Private cCadastro := "Consulta de Oprtunidades"
      Case _Tipo == 2
           Private bFiltraBrw := { || FilBrowse( "SC5" , @aIndex , @cFiltro2 ) } 
           Private cCadastro := "Consulta de Pedido de venda"
      Case _Tipo == 3
           Private bFiltraBrw := { || FilBrowse( "ADY" , @aIndex , @cFiltro3 ) } 
           Private cCadastro := "Consulta de Proposta Comercial"

   EndCase        

   //Efetiva o Filtro antes da Chamada a mBrowse
   Eval( bFiltraBrw )    

   Do Case
      Case _Tipo == 1
           mBrowse( 6 , 1 , 22 , 75 , "AD1" )
           EndFilBrw( "AD1" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 2
           mBrowse( 6 , 1 , 22 , 75 , "SC5", .f. )
           EndFilBrw( "SC5" , @aIndex ) //Finaliza o Filtro

      Case _Tipo == 3
           mBrowse( 6 , 1 , 22 , 75 , "ADY", .f. )
           EndFilBrw( "ADY" , @aIndex ) //Finaliza o Filtro

   EndCase        

Return( NIL )

// ###################################################################################
// Função que mostra dados do contrato quando usuário selecionar o botão visualizar ##
// ###################################################################################
Static Function MostraDtl()

   Local cSql    := ""
   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Local cRetorno   := ""
   Local cInformacao := ""

//   Local nPosCodigo := aScan( aHeader, { |x| x[2] == 'AB7_CODPRO' } )
//   Local nPosSeries := aScan( aHeader, { |x| x[2] == 'AB7_NUMSER' } )   

   Private oDlgINFO

   // ##############################################################################################
   // Pesquisa para ver se o número de serie informado está vinculado a um contrato de manutenção ##
   // ##############################################################################################
   If Select("T_CONTRATO") > 0
      T_CONTRATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA3.AA3_FILIAL,"
   cSql += "       AA3.AA3_CODCLI,"
   cSql += "       AA3.AA3_LOJA  ,"
   cSql += "       AA3.AA3_CONTRT,"
   cSql += "       AA3.AA3_CODPRO,"
   cSql += "       AA3.AA3_NUMSER,"
   cSql += "       (SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AAH_INFO))"
   cSql += "          FROM AAH" + Substr(cComboBx2,01,02) + "0 (NOLOCK)"
   cSql += "         WHERE AAH_FILIAL = AA3.AA3_FILIAL"
   cSql += "          AND AAH_CONTRT  = AA3.AA3_CONTRT"
   cSql += "          AND D_E_L_E_T_  = '') AS INFORMACAO"
   cSql += "  FROM AA3" + Substr(cComboBx2,01,02) + "0 AA3 (NOLOCK)"
   cSql += " WHERE AA3_FILIAL  = '" + Alltrim(aLista[oLista:nAt,15]) + "'"
   cSql += "   AND AA3_CODCLI  = '" + Alltrim(aLista[oLista:nAt,08]) + "'"
   cSql += "   AND AA3_LOJA    = '" + Alltrim(aLista[oLista:nAt,09]) + "'"
   cSql += "   AND AA3_CODPRO  = '" + Alltrim(aLista[oLista:nAt,12]) + "'"
   cSql += "   AND AA3_NUMSER  = '" + Alltrim(aLista[oLista:nAt,11]) + "'"
   cSql += "   AND AA3_CONTRT <> ''"
   cSql += "   AND D_E_L_E_T_  = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

   If T_CONTRATO->( EOF() )
      Return(cRetorno)
   Else
      cInformacao := ""
      cInformacao := "Produto: "     + Alltrim(aLista[oLista:nAt,12]) + " - " + Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")  + aLista[oLista:nAt,12], "B1_DESC")) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Nº de Série: " + Alltrim(aLista[oLista:nAt,11])                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Está vinculado ao contrato de nº " + Alltrim(T_CONTRATO->AA3_CONTRT) + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "INFORMAÇÕES GERAIS DO CONTRATO DE MANUTENÇÃO:"                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     Alltrim(T_CONTRATO->INFORMACAO)                                       + chr(13) + chr(10)
   Endif

   DEFINE MSDIALOG oDlgINFO TITLE "Informação de Vínculo de Contrato ao Equipamento" FROM C(178),C(181) TO C(485),C(654) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgINFO

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(229),C(001) PIXEL OF oDlgINFO
   @ C(132),C(002) GET oMemo2 Var cMemo2 MEMO Size C(229),C(001) PIXEL OF oDlgINFO
   
   @ C(036),C(005) Say "Informações referente ao contrato de manutenção" Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlgINFO

   @ C(045),C(005) GET oMemo3 Var cInformacao MEMO Size C(227),C(083) PIXEL OF oDlgINFO

   @ C(137),C(098) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgINFO ACTION( oDlgINFO:End() )
 
   ACTIVATE MSDIALOG oDlgINFO CENTERED 

Return(.T.)





// -------------------

// Função que carrega o grid com as informações do numero de serie informado
Static Function kCARREGAGRID( cSerie, cComboBx1 )

   // Variáveis Locais da Função
   Local oGet1

   // Variáveis da Função de Controle e GertArea/RestArea
   Local _aArea      := {}
   Local _aAlias     := {}
   Local lLibera     := .F.

   Private aComboBx1 := {"EXATA", "INICIANDO", "CONTENDO"}
   Private cComboBx1
   Private oGet1     := Space(20)
   Private aBrowse   := {} 
   Private cSerie    := Space(20)

   // Diálogo Principal
   Private oDlg

   DEFINE FONT oFont Name "Arial" Size 0, -14 BOLD

   // Variáveis que definem a Ação do Formulário

   U_AUTOM628("AUTOMR30")

   DEFINE MSDIALOG oDlg TITLE "Rastreabilidade por Nº de Série" FROM C(178),C(181) TO C(540),C(884) PIXEL

   @ C(010),C(005) Say "Nº de Série:"      Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(090) Say "Tipo Pesquisa:"    Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(030) MsGet oGet1 Var cSerie  Size C(050),C(010) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(008),C(120) ComboBox cComboBx1 Items aComboBx1 Size C(060),C(010) PIXEL OF oDlg

   oBrowse := TSBrowse():New(030,005,440,190,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Operação',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Data',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Etiqueta',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('N.Fiscal',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Série',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Loja',,,{|| },{|| }) )   
   oBrowse:AddColumn( TCColumn():New('Fornecedor/Cliente',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Nº Série',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Produto',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Produtos',,,{|| },{|| }) )

   oBrowse:SetArray(aBrowse)

   @ 007,340  BUTTON "Pesquisar"  Size 50,12 when !Empty(cSerie)    ACTION( CARREGAGRID( cSerie, cComboBx1 ) ) OF oDlg Pixel
   @ 007,395  BUTTON "Voltar"     Size 50,12                        ACTION( odlg:end() )                       OF oDlg Pixel

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)
