#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM516.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 28/11/2016                                                               ##
// Objetivo..: Programa que permite aplicar regra sobre o arquivo Sped Fiscal           ##
// #######################################################################################

User Function AUTOM516()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private lSelecionar := .F.
   Private cCaminho    := Space(250)
   Private oGet1

   Private aRegistros := {"1 - Todos Registros", "2 - C100", "3 - C170", "4 - C190", "5 - Demais Registros", "6 - C100 e C170"}
   Private cComboBx1

   Private aRtotal := {}
   Private aBrowse := {}

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

   Private aBrowse   := {}

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Ajuste Arquivo SPED FISCAL" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(214),C(005) Jpeg FILE "br_verde"    Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(214),C(064) Jpeg FILE "br_vermelho" Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(214),C(120) Jpeg FILE "br_amarelo"  Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(214),C(174) Jpeg FILE "br_laranja"  Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(214),C(228) Jpeg FILE "br_Azul"     Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Informe o arquivo Sped Fiscal a ser lido" Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Registros do arquivo"                     Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(214),C(018) Say "Demais Registros"                         Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(214),C(077) Say "Registros C100"                           Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(214),C(133) Say "Registros C170"                           Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(214),C(188) Say "Registros C190"                           Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(214),C(243) Say "Registros Alterados"                      Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(400) Say "Visualizar Tipo de Registro"              Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(046),C(005) MsGet oGet1        Var   cCaminho   Size C(284),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(291) Button "..."                        Size C(013),C(010)                              PIXEL OF oDlg ACTION( CaptaArquivo() )
   @ C(046),C(308) Button "Importar"                   Size C(037),C(010)                              PIXEL OF oDlg ACTION( ImpSpedFiscal() )
   @ C(046),C(400) ComboBox cComboBx1 Items aRegistros Size C(072),C(010)                              PIXEL OF oDlg When lSelecionar on change VisuRegsitros()
   
   @ C(209),C(297) Button "Visual. Detalhe"   Size C(050),C(012) PIXEL OF oDlg ACTION( MostraDetalhe(aBrowse[oBrowse:nAt,03]) )
   @ C(209),C(350) Button "Aplicar Regra"     Size C(050),C(012) PIXEL OF oDlg ACTION( AplicaRegra() )
   @ C(209),C(403) Button "Gera Novo Arquivo" Size C(056),C(012) PIXEL OF oDlg ACTION( GeraNovoArquivo() )
   @ C(209),C(461) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "7", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'LGE'                    ,; // 01 - legenda
                                                    'ACT'                    ,; // 02 - Registros Alterados 
                                                    'Conteúdo do Registro' } ,; // 03 - Conteúdo do Registro
                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,03]}}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Função que abre diálogo de pesquisa do arquivo a ser importado ##
// #################################################################
Static Function CaptaArquivo()

   cCaminho := cGetFile('*.*', "Selecione o Arquivo Sped Fiscal a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

// #########################################################################
// Função que gera a importação dos dados do arquivo Sped Fiscal indicado ##
// #########################################################################
Static Function ImpSpedFiscal()

   MsgRun("Favor Aguarde! Lendo registros do arquivo ...", "Lendo registros do arquivo",{|| xImpSpedFiscal() })

Return(.T.)

// #########################################################################
// Função que gera a importação dos dados do arquivo Sped Fiscal indicado ##
// #########################################################################
Static Function xImpSpedFiscal()

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aAjuste     := {}
   Local nSepara     := 0
   Local j           := ""

   Private nPosi01   := 0
   Private nPosi02   := 0

   Private lVolta    := .F.
   Private aConsulta := {}
   Private aNaoFez   := {}

   // ######################################################
   // Verifica se o arquivo a ser importado foi informado ##
   // ######################################################
   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não informado ou inexistente.")
      Return .T.
   Endif

   // ############################################
   // Abre o arquivo de inventário especificado ##
   // ############################################
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   aBrowse := {}
   aRTotal := {}

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
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else

          Do Case
             Case U_P_CORTA( cConteudo, "|", 2) == "C100"
                  cLegenda := "9"
             Case U_P_CORTA( cConteudo, "|", 2) == "C170"
                  cLegenda := "3"
             Case U_P_CORTA( cConteudo, "|", 2) == "C190"
                  cLegenda := "6"
             Otherwise
                  cLegenda := "1"                               
          EndCase        

          aAdd( aBrowse, { cLegenda, "7", cConteudo } )
          aAdd( aRtotal, { cLegenda, "7", cConteudo } )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   If Len(aBrowse) == 0
      lSelecionar := .F.
      aAdd( aBrowse, { "7", "7", "" })
      aRtotal := {}
   Else
     lSelecionar := .T.
   Endif   

   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,03]}}

   oBrowse:Refresh()

Return .T.

// ################################################################
// Função que abre a janela com os detalhes da linha selecionada ##
// ################################################################
Static Function MostraDetalhe(_Linha)

   Local cMemo1	   := ""
   Local cDetalhes := ""
   Local oMemo1
   Local oMemo2
   Local nContar := 0

   Private oDlgDet

   If Empty(Alltrim(_Linha))
      MsgAlert("Registro não selecionado para visualização.")
      Return(.T.)
   Endif
   
   cDetalhes := ""   

   For nContar = 1 to U_P_OCCURS(_Linha,"|",1)
       cDetalhes := cDetalhes + Strzero(nContar,05) + " - " + U_P_CORTA(_Linha,"|",nContar) + CHR(13) + CHR(10) 
   Next nContar

   DEFINE MSDIALOG oDlgDet TITLE "Ajuste Arquivo SPED FISCAL" FROM C(178),C(181) TO C(578),C(536) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgDet

   @ C(032),C(002) GET oMemo1 Var cMemo1    MEMO Size C(170),C(001) PIXEL OF oDlgDet
   @ C(036),C(005) GET oMemo2 Var cDetalhes MEMO Size C(167),C(144) PIXEL OF oDlgDet

   @ C(184),C(135) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDet ACTION( oDlgDet:End() )

   ACTIVATE MSDIALOG oDlgDet CENTERED 

Return(.T.)

// ##################################################################################
// Função que seleciona os registros conforme selecionado no combo de visualização ##
// ##################################################################################
Static Function VisuRegsitros()

   Local nContar := 0
   
   aBrowse := {}
   
   For nContar = 1 to Len(aRtotal)
   
       Do Case
          Case Substr(cComboBx1,01,01) == "1"
               aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )

          Case Substr(cComboBx1,01,01) == "2"
               If U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C100"
                  aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )
               Endif
               
          Case Substr(cComboBx1,01,01) == "3"
               If U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C170"
                  aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )
               Endif
                  
          Case Substr(cComboBx1,01,01) == "4"
               If U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C190"
                  aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )
               Endif
               
          Case Substr(cComboBx1,01,01) == "5"
               If U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C100" .And. ;
                  U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C170" .And. ;
                  U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C190"
               Else   
                  aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )
               Endif

          Case Substr(cComboBx1,01,01) == "6"
               If U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C100" .Or. U_P_CORTA(aRtotal[nContar,03], "|", 2) == "C170"
                  aAdd( aBrowse, { aRtotal[nContar,01], aRtotal[nContar,02], aRtotal[nContar,03] } )
               Endif

       EndCase
       
   Next nContar

   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,03]}}

   oBrowse:Refresh()

Return(.T.)

// #########################################################################
// Função que gera a importação dos dados do arquivo Sped Fiscal indicado ##
// #########################################################################
Static Function AplicaRegra()

   MsgRun("Favor Aguarde! Aplicando Regra nos registros ...", "Aplicando Regra nos Registros",{|| xAplicaRegra() })

Return(.T.)

// ######################################################
// Função que aplica a regra nos registros C100 e C170 ##
// ######################################################
Static Function xAplicaRegra()

   Local cSql    := ""
   Local nContar := 0
   Local nSepara := 0
   Local cString := ""
   
   // ##################################################
   // Aplica a primeira regra sobre os registros C100 ##
   // ##################################################
   For nContar = 1 to Len(aRtotal)
   
       If U_P_CORTA(aRtotal[nContar,03], "|", 02) == "C100"
       
          cChaveNf := U_P_CORTA(aRtotal[nContar,03], "|", 10)

          If Select("T_REGRA01") > 0
             T_REGRA01->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT SUM(F3_ICMSRET) AS ICMSRET"
          cSql += "  FROM " + RetSqlName("SF3")
          cSql += " WHERE F3_CHVNFE  = '" + Alltrim(cChaveNf) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REGRA01", .T., .T. )
          
          If T_REGRA01->( EOF() )
             Loop
          Endif
          
          If T_REGRA01->ICMSRET == 0
             Loop
          Endif

          nSepara := 0
          cString := ""

          For nSepara = 1 to U_P_OCCURS(aRtotal[nContar,03],"|",1)

              If nSepara == 25
                 cString := cString + StrTran(Alltrim(STR(T_REGRA01->ICMSRET,10,02)), ".", ",") + "|"
              Else              
                 cString := cString + U_P_CORTA(aRtotal[nContar,03],"|",nSepara) + "|"
              Endif
              
          Next nSepara
       
          // #######################################
          // Atualiza o registro no array aRtotal ##
          // #######################################
          aRtotal[nContar,02] := "5"
          aRtotal[nContar,03] := cString

       Endif
       
   Next nContar

   // #################################################
   // Aplica a segunda regra sobre os registros C170 ##
   // #################################################
   For nContar = 1 to Len(aRtotal)
   
       If U_P_CORTA(aRtotal[nContar,03], "|", 02) == "C100"

          cChaveNf := U_P_CORTA(aRtotal[nContar,03], "|", 10)

          Loop

       Endif
                 
       If U_P_CORTA(aRtotal[nContar,03], "|", 02) == "C170"

          cCodItem    := Strzero(INT(VAL(U_P_CORTA(aRtotal[nContar,03], "|", 03))),4)
          cCodProduto := U_P_CORTA(aRtotal[nContar,03], "|", 04)

          If Select("T_PRODUTOS") > 0
             T_PRODUTOS->( dbCloseArea() )
          EndIf

          cSql := "SELECT SF1.F1_FILIAL,"
          cSql += "       SF1.F1_DOC   ,"
	      cSql += "       SF1.F1_SERIE ,"
	      cSql += "       SF1.F1_CHVNFE,"
	      cSql += "       SD1.D1_COD   ,"
	      cSql += "       SD1.D1_ICMSRET"
          cSql += "  FROM " + RetSqlName("SF1") + " SF1, "
          cSql += "       " + RetSqlName("SD1") + " SD1  "
          cSql += " WHERE SF1.F1_CHVNFE  = '" + Alltrim(cChaveNf) + "'"
          cSql += "   AND SF1.D_E_L_E_T_ = ''"
          cSql += "   AND SD1.D1_FILIAL  = SF1.F1_FILIAL"
          cSql += "   AND SD1.D1_DOC     = SF1.F1_DOC   "
          cSql += "   AND SD1.D1_ITEM    = '" + Alltrim(cCodItem)    + "'"
          cSql += "   AND SD1.D1_COD     = '" + Alltrim(cCodProduto) + "'"
          cSql += "   AND SD1.D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

          If T_PRODUTOS->( EOF() )
             Loop
          Endif
             
	      If T_PRODUTOS->D1_ICMSRET == 0
	         Loop
	      Endif
 
          // ################################################### 
          // Prepara a String para atualizão do array aRtotal ##
          // ###################################################
          nSepara := 0
          cString := ""

          For nSepara = 1 to U_P_OCCURS(aRtotal[nContar,03],"|",1)

              If nSepara == 19
                 cString := cString + StrTran(Alltrim(STR(T_PRODUTOS->D1_ICMSRET,10,02)), ".", ",") + "|"
              Else              
                 cString := cString + U_P_CORTA(aRtotal[nContar,03],"|",nSepara) + "|"
              Endif
              
          Next nSepara
       
          // #######################################
          // Atualiza o registro no array aRtotal ##
          // #######################################
          aRtotal[nContar,02] := "5"
          aRtotal[nContar,03] := cString

       Endif
       
   Next nContar

   // #####################################################################
   // Aplica a terceira regra sobre os registros C170                    ##
   // ------------------------------------------------------------------ ##
   // Se o conteúdo do campo 24 do C170 for == a 0, o campo 20 recebe 49 ##
   // Se o conteúdo do campo 24 do C170 for <> a 0, o campo 20 recebe 00 ##  
   // #####################################################################
   For nContar = 1 to Len(aRtotal)
   
       If U_P_CORTA(aRtotal[nContar,03], "|", 02) == "C170"

          cCampo24 := VAL(U_P_CORTA(aRtotal[nContar,03], "|", 25))
 
          // ################################################### 
          // Prepara a String para atualizão do array aRtotal ##
          // ###################################################
          nSepara := 0
          cString := ""

          For nSepara = 1 to U_P_OCCURS(aRtotal[nContar,03],"|",1)

              If nSepara == 21
                 If cCampo24 == 0
                    cString := cString + "49|"
                 Else
                    cString := cString + "00|"                    
                 Endif
              Else              
                 cString := cString + U_P_CORTA(aRtotal[nContar,03],"|",nSepara) + "|"
              Endif
              
          Next nSepara
       
          // #######################################
          // Atualiza o registro no array aRtotal ##
          // #######################################
          aRtotal[nContar,02] := "5"
          aRtotal[nContar,03] := cString

       Endif
       
   Next nContar

   // #############################################################################################################
   // Verifica o tamanho do conteúdo do registro 7. Este deve ser tamanho = 14 (CNPJ)                            ##
   // Se for CNPJ, verifica o conteúdo do | 6. Se este estiver vazio, recompor o registro com | no final do CNPJ ##
   // #############################################################################################################
   For nContar = 1 to Len(aRtotal)

       If U_P_CORTA(aRtotal[nContar,03], "|", 02) == "0150"
       
          If Len(U_P_CORTA(aRtotal[nContar,03], "|", 07)) == 14

             If Empty(Alltrim(U_P_CORTA(aRtotal[nContar,03], "|", 06)))
             
                cString :=        U_P_CORTA(aRtotal[nContar,03], "|", 01) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 02) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 03) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 04) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 05) + ;                           
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 07) + ;
                           "||" + U_P_CORTA(aRtotal[nContar,03], "|", 08) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 09) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 10) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 11) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 12) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 13) + ;
                           "|"  + U_P_CORTA(aRtotal[nContar,03], "|", 14) + "|"

                // #######################################
                // Atualiza o registro no array aRtotal ##
                // #######################################
                aRtotal[nContar,02] := "5"
                aRtotal[nContar,03] := cString

             Endif
             
          Endif
       
       Endif
       
   Next nContar           

   // ######################################
   // Refresh no grid após regra aplicada ##
   // ######################################
   cComboBx1 := "1 - Todos Registros"
   VisuRegsitros()
   
Return(.T.)

// #######################################################
// Função que gera novo arquivo após aplicação da regra ##
// #######################################################
Static Function GeraNovoArquivo()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cNomeArquivo := Space(30)
   Private cPastaGravar := Space(250)
   Private oGet1
   Private oGet2

   Private oDlgGera

   If Len(abrowse) == 0
      MsgAlert("Não existem dados a serem gravados.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(aBrowse[01,03]))
      MsgAlert("Não existem dados a serem gravados.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgGera TITLE "Ajuste Arquivo Sped Fiscal" FROM C(178),C(181) TO C(396),C(667) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgGera

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlgGera
   @ C(084),C(002) GET oMemo2 Var cMemo2 MEMO Size C(234),C(001) PIXEL OF oDlgGera

   @ C(037),C(005) Say "Nome do arquivo a ser gerado"        Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgGera
   @ C(059),C(005) Say "Caminho onde o arquivo será gravado" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgGera

   @ C(046),C(005) MsGet oGet1 Var cNomeArquivo Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgGera
   @ C(068),C(005) MsGet oGet2 Var cPastaGravar Size C(219),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgGera When lChumba
   @ C(068),C(228) Button "..."          Size C(010),C(009)                                     PIXEL OF oDlgGera ACTION( BscCaminho() )

   @ C(092),C(082) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlgGera ACTION( GerarArqSped() )
   @ C(092),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgGera ACTION( oDlgGera:End() )
   
   ACTIVATE MSDIALOG oDlgGera CENTERED 

Return(.T.)

// ############################################################################
// Função que abre diálogo para seleção do caminho de gravação do arquvo TXT ##
// ############################################################################
Static Function BscCaminho()

   cPastaGravar := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

Return(.T.)

// ################################################
// Função que gera o novo arquivo do Sped Fiscal ##
// ################################################
Static Function GerarArqSped()

   MsgRun("Favor Aguarde! Gerando novo arquivo Sped Fiscal ...", "gerando Arquivo Sped Fiscal",{|| xGerarArqSped() })

Return(.T.)

// ################################################
// Função que gera o novo arquivo do Sped Fiscal ##
// ################################################
Static Function xGerarArqSped()

   Local cString := ""
   Local nContar := 0

   // #####################################################
   // Consiste os dados antes da geração do novo arquivo ##
   // #####################################################
   If Empty(Alltrim(cNomeArquivo))
      MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Nome do arquivo a ser gravadio não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cPastaGravar))
      MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Caminho de gravação do arquivo não informado.")
      Return(.T.)
   Endif
      
   // ###################################################
   // Prepara o conteúdo para gravação do novo arquivo ##
   // ###################################################
   cString := ""
   For nContar = 1 to Len(aRtotal)
       cString := cString + aRtotal[nContar,03] + chr(13) + chr(10)
   Next nContar

   // Gera o arquivo XML para o caminho informado
   nHdl := fCreate(Alltrim(cPastaGravar) + Alltrim(cNomeArquivo))
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   MsgAlert("Arquivo " + Alltrim(cPastaGravar) + Alltrim(cNomeArquivo) + " gerado com sucesso.")

   oDlgGera:End()
   
   aBrowse := {}
   aRTotal := {}    
   aAdd( aBrowse, { "7", "7", "" })

   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,02]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,03]}}

   oBrowse:Refresh()

Return(.T.)