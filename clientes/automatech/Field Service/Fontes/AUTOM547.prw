#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM547.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 07/03/2017                                                          ##
// Objetivo..: Importador de Base Instalade de Clientes                            ##
// ##################################################################################

User Function AUTOM547()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
                                                             
   Private cCaminho := Space(250)
   Private oGet3

   Private aBrowse  := {}
   
   // ######################
   // Declara as Legendas ##
   // ######################
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

   DEFINE MSDIALOG oDlg TITLE "Importação Base Instalada" FROM C(178),C(181) TO C(586),C(957) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg
   @ C(190),C(069) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(190),C(164) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Informe arquivo de base instalada a ser importada" Size C(120),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(083) Say "Nºs de Série a serem importados"                   Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(191),C(178) Say "Nºs de Séries já importados"                       Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet oGet3 Var cCaminho Size C(270),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(046),C(279) Button "..."            Size C(013),C(009) PIXEL OF oDlg ACTION( BscArqBase() )
   @ C(043),C(295) Button "Importar"       Size C(037),C(012) PIXEL OF oDlg ACTION( ImpBaseInst() )
   @ C(043),C(336) Button "Layout Arquivo" Size C(047),C(012) PIXEL OF oDlg ACTION( LayoutArqB() )

   @ C(188),C(005) Button "Efetivar Importação"        Size C(058),C(012) PIXEL OF oDlg ACTION( GravaBaseInst() )
   @ C(188),C(347) Button "Voltar"                     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
  
   @ 077,005 LISTBOX oBrowse FIELDS HEADER "LG", "Cliente", "Loja", "Nome Clientes", "Produto", "Descrição dos Produtos", "Nº de Série", "NF Venda", "Data Venda", "Cod.Fab.", "Loja Fab.", "Nome Fabricante"PIXEL SIZE 487,160 OF oDlg ;
                            ON dblClick(aBrowse[oBrowse:nAt,1] := !aBrowse[oBrowse:nAt,1],oBrowse:Refresh())     

   aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               ,;
                         aBrowse[oBrowse:nAt,07]               ,;
                         aBrowse[oBrowse:nAt,08]               ,;
                         aBrowse[oBrowse:nAt,09]               ,;
                         aBrowse[oBrowse:nAt,10]               ,;
                         aBrowse[oBrowse:nAt,11]               ,;
                         aBrowse[oBrowse:nAt,12]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###################################################################
// Função que abre janela para selecionar o arquivo a ser importado ##
// ###################################################################
Static Function BscArqBase()

   cCaminho := cGetFile('*.txt', "Selecione o arquivo a ser importado",1,,.F.,16,.F.)

Return(.T.)

// ##############################################################################
// Função que abre janela para visualização do layout do arquivo de importação ##
// ##############################################################################
Static Function LayoutArqB()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local cString := ""

   Private oDlgL

   cString := ""
   cString := cString + "003870;001;002953;0450807292081456;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;007824;0450807292081456;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;007824;0450807292081467;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;001874;0450807292081475;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;007824;0450807292081475;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;005052;0450807292081476;004965;002" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081478;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;007824;0450807292081478;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081530;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081535;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081788;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081816;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081820;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;008361;0450807292081820;004965;001" + chr(13) + chr(10) + ;
                        "003870;001;002994;0450807292081835;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081835;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081840;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;002953;0450807292081845;004108;001" + chr(13) + chr(10) + ;
                        "003870;001;005052;0450807292081847;004965;001" + chr(13) + chr(10)

   DEFINE MSDIALOG oDlgL TITLE "Importação Base Instalada" FROM C(178),C(181) TO C(519),C(807) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgL

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(305),C(001) PIXEL OF oDlgL
   @ C(139),C(005) GET oMemo3 Var cMemo3 MEMO Size C(191),C(001) PIXEL OF oDlgL
   
   @ C(037),C(005) Say "Layout do arquivo de importação de Base Instalada" Size C(124),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(131),C(005) Say "Descrição das colunas"                             Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(142),C(005) Say "1ª Coluna: Código do Cliente"                      Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(142),C(102) Say "4ª Coluna: Número de Série do Produto"             Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(151),C(005) Say "2ª Coluna: Loja do Cliente"                        Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(151),C(102) Say "5ª Coluna: Código do Fabricante"                   Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(160),C(005) Say "3ª Coluna: Código do Produto"                      Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(160),C(102) Say "6ª Coluna: Loja do Fabricante"                     Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(142),C(211) Say "Arquivo no formato CSV"                            Size C(097),C(008) COLOR CLR_RED   PIXEL OF oDlgL
	   
   @ C(047),C(005) GET oMemo2 Var cString MEMO Size C(303),C(081) PIXEL OF oDlgL When lChumba

   @ C(155),C(270) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// ##########################################################################
// Função que importa a base instalada pela leitura do arquivo selecionado ##
// ##########################################################################
Static Function ImpBaseInst()
           
   MsgRun("Favor Aguarde! Importando arquivo de Base Instalada ...", "Importação Base Instalada",{|| xImpBaseInst() })

Return(.T.)

// ##########################################################################
// Função que importa a base instalada pela leitura do arquivo selecionado ##
// ##########################################################################
Static Function xImpBaseInst()

   Local cSql := ""
 
   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não informado.")
      Return(.T.)
   Endif
   
   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo inexistente.")
      Return(.T.)
   Endif

   aBrowse := {}

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               ,;
                         aBrowse[oBrowse:nAt,07]               ,;
                         aBrowse[oBrowse:nAt,08]               ,;
                         aBrowse[oBrowse:nAt,09]               ,;
                         aBrowse[oBrowse:nAt,10]               ,;
                         aBrowse[oBrowse:nAt,11]               ,;
                         aBrowse[oBrowse:nAt,12]               }}

   // #######################################################
   // Lê arquivo selecionado para carregar o array aBrowse ##
   // #######################################################
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + ";"
          _Linha    := ""

          // ##############################################################
          // Pesquisa Nº Nota Fiscxal e Data da Venda do número de série ##
          // ##############################################################
          If Select("T_VENDA") > 0
             T_VENDA->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_DOC,"
          cSql += "       SUBSTRING(DB_DATA,07,02) + '/' + SUBSTRING(DB_DATA,05,02) + '/' + SUBSTRING(DB_DATA,01,04) AS EMISSAO "
          cSql += "  FROM " + RetSqlName("SDB") + " (Nolock) "
          cSql += " WHERE DB_NUMSERI = '" + Alltrim(U_P_CORTA(cConteudo,";",04)) + "'"
          cSql += "   AND DB_ORIGEM  = 'SC6'"
          cSql += "   AND DB_CLIFOR  = '" + Alltrim(STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",01))),6)) + "'"
          cSql += "   AND DB_LOJA    = '" + Alltrim(STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",02))),3)) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"
       
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDA", .T., .T. )

          kDocumento := IIF(T_VENDA->( EOF() ), ""          , T_VENDA->DB_DOC)
          kEmissao   := IIF(T_VENDA->( EOF() ), "  /  /    ", T_VENDA->EMISSAO)

          // #######################################
          // Trata a legenda para o registro lido ##
          // #######################################
          If Select("T_LEGENDA") > 0
             T_LEGENDA->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT AA3_NUMSER "
          cSql += "  FROM " + RetSqlName("AA3") + " (Nolock) "
          cSql += "WHERE AA3_CODCLI  = '" + Alltrim(STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",01))),6)) + "'"
          cSql += "  AND AA3_LOJA    = '" + Alltrim(STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",02))),3)) + "'"
          cSql += "  AND AA3_CODPRO  = '" + Alltrim(STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",03))),6)) + "'"
          cSql += "  AND AA3_NUMSER  = '" + Alltrim(U_P_CORTA(cConteudo,";",04)) + "'"
          cSql += "  AND D_E_L_E_T_  = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LEGENDA", .T., .T. )

          kLegenda := IIF(T_LEGENDA->( EOF() ), "2", "8")

          // ###################################################
          // Carrega o array aBrowse com os dados pesquisados ##
          // ###################################################
          kCliente := STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",01))),6)
          kLoja    := STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",02))),3)
          kProduto := STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",03))),6)
          kCodFabr := STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",05))),6)
          kLojFabr := STRZERO(INT(VAL(U_P_CORTA(cConteudo,";",06))),3)

          aAdd( aBrowse,{ kLegenda                                                           ,;
                          kCliente                                                           ,;
                          kLoja                                                              ,;
                          POSICIONE("SA1",1,XFILIAL("SA1") + kCliente + kLoja, "A1_NOME")    ,;
                          kProduto                                                           ,;
                          POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_DESC")            ,;
                          U_P_CORTA(cConteudo,";",04)                                        ,;
                          kDocumento                                                         ,;
                          kEmissao                                                           ,;
                          kCodFabr                                                           ,;
                          kLojFabr                                                           ,;
                          POSICIONE("SA2",1,XFILIAL("SA2") + kCodFabr + kLojFabr, "A2_NOME") })

          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "", "", "" })
   Endif   

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               ,;
                         aBrowse[oBrowse:nAt,07]               ,;
                         aBrowse[oBrowse:nAt,08]               ,;
                         aBrowse[oBrowse:nAt,09]               ,;
                         aBrowse[oBrowse:nAt,10]               ,;
                         aBrowse[oBrowse:nAt,11]               ,;
                         aBrowse[oBrowse:nAt,12]               }}

Return(.T.)

// ########################################################################
// Função que grava na tabela AA3 os registros liberados para importação ##
// ########################################################################
Static Function GravaBaseInst()

   Local nContar      := 0
   Local lTemRegistro := .F.
   
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == "2"
          lTemRegistro := .T.
          Exit
       Endif
   Next nContar
   
   If lTemRegistro == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Não existem registros a serem incluídos na base instalada." + chr(13) + chr(10) + "Veirifque legenda dos registros.")
      Return(.T.)
   Endif

   // ###################### 
   // Inclui os registros ##
   // ######################
   For nContar = 1 to Len(aBrowse)
       DBSelectArea("AA3")     
       DbSetOrder(1)
//  	 RecLock("AA3",.T.)
//       AA3->AA3_FILIAL := cFilAnt
//       AA3->AA3_CODCLI := aBrowse[nContar,02]
//       AA3->AA3_LOJA   := aBrowse[nContar,03]
//       AA3->AA3_CODPRO := aBrowse[nContar,05]
//       AA3->AA3_NUMSER := aBrowse[nContar,07]
//       AA3->AA3_DTVEND := aBrowse[nContar,08]
//       AA3->AA3_NFVEND := Ctod(aBrowse[nContar,09])
//       AA3->AA3_CODFAB := aBrowse[nContar,10]
//       AA3->AA3_LOJAFA := aBrowse[nContar,11]
//       AA3->AA3_STATUS := "01"
//	   MsUnlock()
   Next nContar

   MsgAlert("Base Instalada atualizada com sucesso.")
   
Return(.T.)