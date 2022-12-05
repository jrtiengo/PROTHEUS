#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM643.PRW                                                            ##
// Par�metros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                                 ##
// Data......: 04/10/2017                                                              ##
// Objetivo..: Importa��o de Contratos Assist�ncia T�cnica                             ##
// ######################################################################################

User Function AUTOM643()

   Local lChumba  := .F.
   Local cMemo1	  := ""

   Local oMemo1

   Private cCaminho := Space(254)
   Private oGet1

   Private aLista    := {}
   Private oLista

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

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

   DEFINE MSDIALOG oDlg TITLE "Importa��o de Contratos Assist�ncia T�cnica" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(033),C(005) Say "Arquivo de contratos a ser utilizado para a importa��o" Size C(131),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(043),C(005) MsGet oGet1 Var cCaminho Size C(211),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(043),C(217) Button "..."                          Size C(015),C(009) PIXEL OF oDlg ACTION( BSCCNTAT() )
   @ C(040),C(235) Button "Abrir Arquivo"                Size C(043),C(012) PIXEL OF oDlg ACTION( IMPCNTAT(0) )
   @ C(210),C(005) Button "Marca Todos"                  Size C(047),C(012) PIXEL OF oDlg ACTION( MRCREGALISTA(1) )
   @ C(210),C(053) Button "Desmarca Todos"               Size C(047),C(012) PIXEL OF oDlg ACTION( MRCREGALISTA(0) )
   @ C(210),C(102) Button "Importar"                     Size C(045),C(012) PIXEL OF oDlg ACTION( IMPCNTAT(1) )
   @ C(210),C(226) Button "Layout Arquivo de Importa��o" Size C(084),C(012) PIXEL OF oDlg ACTION( LAYOUTCNTAT() )
   @ C(210),C(461) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   @ 078,005 LISTBOX oLista FIELDS HEADER "MRC"                      ,; // 01
                                          "Leg"                      ,; // 02
                                          "Empresa"                  ,; // 03
                                          "Filial"                   ,; // 04
                                          "Cliente"                  ,; // 05
                                          "Loja"                     ,; // 06
                                          "Descri��o dos Clientes"   ,; // 07
                                          "N� Contrato"              ,; // 08
                                          "Produto"                  ,; // 09
                                          "Descri��o dos Produtos"   ,; // 10
                                          "N� de S�rie"              ,; // 11
                                          "Fabricante"               ,; // 12
                                          "Loja"                     ,; // 13
                                          "Descri��o dos Fabricantes",; // 14
                                          "Status de Importa��o" + Space(100) ; // 15
                                          PIXEL SIZE 633,187 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
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

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##############################################################################
// Fun��o que abre di�logo de pesquisa do arquivo de contratos a ser importado ##
// ##############################################################################
Static Function BSCCNTAT()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)

Return(.T.)

// #########################################################
// Fun��o que marca/desmarca os registros do array aLista ##
// #########################################################
Static Function MRCREGALISTA(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[ncontar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// #####################################################
// Layout do arquivo de Importa��o de Contratos da AT ##
// #####################################################
Static Function LAYOUTCNTAT()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cString := ""
   Local oMemo1
   Local oMemo2

   DEFINE FONT oFont Name "Courier New" Size 0, 14
   
   Private oDlgCNT

   cString := ""
   cString += "NOME DOS CAMPOS          TIPO   TAMANHO   DECIMAL   OBSERVA��O" + CHR(13) + CHR(10)
   cString += "------------------------ ------ --------- --------- ----------" + CHR(13) + CHR(10)
   cString += "EMPRESA                  C         02        00               " + CHR(13) + CHR(10)
   cString += "FILIAL                   C         02        00               " + CHR(13) + CHR(10)
   cString += "CLIENTE                  C         06        00               " + CHR(13) + CHR(10)
   cString += "LOJA                     C         03        00               " + CHR(13) + CHR(10)
   cString += "N�MERO DO CONTRATO       C         15        00               " + CHR(13) + CHR(10)
   cString += "PRODUTO/EQUIPAMENTO      C         30        00               " + CHR(13) + CHR(10)
   cString += "N�MERO DE S�RIE          C         20        00               " + CHR(13) + CHR(10)
   cString += "FABRICANTE               C         06        00               " + CHR(13) + CHR(10)
   cString += "LOJA DO FABRICANTE       C         03        00               " + CHR(13) + CHR(10)

   DEFINE MSDIALOG oDlgCNT TITLE "Layout do Arquivo de Importa��o de Contratos - AT" FROM C(178),C(181) TO C(558),C(634) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(106),C(022) PIXEL NOBORDER OF oDlgCNT

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(220),C(001) PIXEL OF oDlgCNT

   @ C(177),C(005) Say "ARQUIVO DEVE SER GRAVADO NO FORMATO CSV SEPARADO POR ;" Size C(179),C(008) COLOR CLR_BLACK PIXEL OF oDlgCNT

   @ C(032),C(005) GET oMemo2 Var cString MEMO FONT oFont Size C(218),C(140) PIXEL OF oDlgCNT When lChumba

   @ C(174),C(186) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgCNT ACTION( oDlgCNT:End() )

   ACTIVATE MSDIALOG oDlgCNT CENTERED 

Return(.T.)

// ################################################
// Fun��o que realiza a importa��o dos contratos ##
// ################################################
Static Function IMPCNTAT(kTipo)

   If kTipo == 0
      MsgRun("Aguarde! Abrindo arquivo de importa��o de N� de S�ries ...", "Importa��o",{|| xIMPCNTAT(kTipo) })
   Else
      MsgRun("Aguarde! Importando arquivo de importa��o de N� de S�ries ...", "Importa��o",{|| xIMPCNTAT(kTipo) })      
   Endif
   
Return(.T.)   

// ################################################
// Fun��o que realiza a importa��o dos contratos ##
// ################################################
Static Function xIMPCNTAT(kTipo)

   Local nContar  := 0

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo de contratos a ser importado n�o selecionado. Verifique!")
      Return(.T.)
   Endif

   If kTipo == 0

      // ####################################################
      // Abre o arquivo selecionado para pesquisa de dados ##
      // ####################################################
      nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
      If FERROR() != 0
         MsgAlert("Erro ao abrir o arquivo de importa��o.")
         FCLOSE(cCaminho)
         FCLOSE(nHandle)
         Return(.T.)
      Endif
  
      // ################################
      // L� o tamanho total do arquivo ##
      // ################################
      nLidos := 0
      FSEEK(nHandle,0,0)
      nTamArq := FSEEK(nHandle,0,2)
      FSEEK(nHandle,0,0)

      // ########################
      // L� todos os Registros ##
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

      // ###############################################################
      // Carrega os array aCabec e aItens para inclus�o dos contratos ##
      // ###############################################################
      aLista := {}

      For nContar = 1 to U_P_OCCURS(cString, CHR(10), 1)

          // ##############################################
          // L� linha por linha do arquivo de importa��o ##
          // ##############################################
          cConteudo := U_P_CORTA(cString, CHR(10), nContar) + ";"

          // ################################################################################################
          // Separa os dados em campo spara grava��o da base instalada e vincula��o ao contrato do cliente ##
          // ################################################################################################
          kEmpresa    := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 01))),02)
          kFilial     := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 02))),02)
          kCliente    := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 03))),06)
          kLoja       := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 04))),03)
          kContrato   := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 05))),15)
          kProduto    := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 06))),06) + Space(24)
          kNumSerie   := Alltrim(U_P_CORTA(cConteudo, ";", 07)) + Space(20 - Len(Alltrim(U_P_CORTA(cConteudo, ";", 07))))
          kFabricante := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 08))),06)
          kLojaFab    := Strzero(INT(VAL(U_P_CORTA(cConteudo, ";", 09))),03)
    
          kNomeCli    := POSICIONE("SA1",1,XFILIAL("SA1") + kCliente + kLoja,"A1_NOME")
          kNomePro    := Alltrim(POSICIONE("SB1",1,XFILIAL("SB1") + kProduto,"B1_DESC")) + " " + ;
                      Alltrim(POSICIONE("SB1",1,XFILIAL("SB1") + kProduto,"B1_DAUX"))
          kNomeFab    := POSICIONE("SA2",1,XFILIAL("SA2") + kFabricante + kLojaFab,"A2_NOME")
       
          aAdd(aLista, { .F.        ,; // 01                        
                         "0"        ,; // 02
                         kEmpresa   ,; // 03
                         kFilial    ,; // 04
                         kCliente   ,; // 05
                         kLoja      ,; // 06
                         kNomeCli   ,; // 07                        
                         kContrato  ,; // 08
                         kProduto   ,; // 09
                         kNomePro   ,; // 10
                         kNumSerie  ,; // 11
                         kFabricante,; // 12
                         kLojaFab   ,; // 13
                         kNomeFab   ,; // 14
                         ""         }) // 15

      Next nContar                        
      
   Else
   
      lMarcado := .F.
      
      For nContar = 1 to Len(aLista)
          If aLista[nContar,01] == .T.
             lMarcado := .T.
             Exit
          Endif
      Next nContar
      
      If lMarcado == .F.
         MsgAlert("Aten��o! Nenhum registro foi marcado para ser importado. Verifique!")
         Return(.T.)
      Endif
   
   Endif   
   
   // #########################################
   // Realiza a manuten��o da base instalada ##
   // #########################################
   For nContar = 1 to Len(aLista)

       If kTipo == 0
       Else
          If aLista[nContar,01] == .F.
             Loop
          Endif   
       Endif   
   
       If aLista[nContar,03] <> cEmpAnt
          aLista[nContar,02] := "8"
          aLista[nContar,15] := "Empresa do arquivo de importa��o diferente da Empresa logada."
          Loop
       Endif
          
       If aLista[nContar,04] <> cFilAnt
          aLista[nContar,02] := "8"
          aLista[nContar,15] := "Filial do arquivo de importa��o diferente da Filial logada."
          Loop
       Endif

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
       cSql += "    FROM " + RetSqlName("AA3") + " AA3 "
       cSql += "   WHERE AA3_FILIAL     = '" + Alltrim(aLista[nContar,04]) + "'"
       cSql += "     AND AA3_CODPRO     = '" + Alltrim(aLista[nContar,09]) + "'"
       cSql += "     AND AA3_NUMSER     = '" + Alltrim(aLista[nContar,11]) + "'"
       cSql += "     AND AA3.D_E_L_E_T_ = ''

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

       If T_SERIES->( EOF() )

          aLista[nContar,02] := "5"
          aLista[nContar,15] := "N� de s�rie ser� inclu�do na base instalada."
          
          // ####################################################################
          // Pesquisa a data e nota fiscal de venda do produto/n�mero de s�rie ##
          // ####################################################################
          If Select("T_VENDA") > 0
             T_VENDA->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT DB_FILIAL ,"
          cSql += "       DB_PRODUTO,"
          cSql += "       DB_NUMSERI,"
          cSql += "       DB_DOC    ,"
	      cSql += "       DB_DATA    "
          cSql += "  FROM " + RetSqlName("SDB")
          cSql += " WHERE DB_FILIAL  = '" + Alltrim(aLista[nContar,04]) + "'"
          cSql += "   AND DB_PRODUTO = '" + Alltrim(aLista[nContar,09]) + "'"
          cSql += "   AND DB_NUMSERI = '" + Alltrim(aLista[nContar,11]) + "'"
          cSql += "   AND DB_CLIFOR  = '" + Alltrim(aLista[nContar,05]) + "'"
          cSql += "   AND DB_LOJA    = '" + Alltrim(aLista[nContar,06]) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDA", .T., .T. )

          If T_VENDA->( EOF() )
             kDocumento := ""
             kDataVenda := ""
          Else
             kDocumento := T_VENDA->DB_DOC
             kDataVenda := T_VENDA->DB_DATA
          Endif   

          // ######################################
          // Inclui o registro na base instalada ##
          // ######################################
          If kTipo == 0
          Else
   	         RecLock("AA3",.T.)
             AA3->AA3_FILIAL := aLista[nContar,04]
             AA3->AA3_CODCLI := aLista[nContar,05]
             AA3->AA3_LOJA   := aLista[nContar,06]
             AA3->AA3_CODPRO := aLista[nContar,09]
             AA3->AA3_NUMSER := aLista[nContar,11]
             AA3->AA3_CONTRT := aLista[nContar,08]

             If Empty(Alltrim(kDocumento ))
             Else
                AA3->AA3_DTVEND := kDocumento
                AA3->AA3_NFVEND := kDataVenda
             Endif   

             AA3->AA3_CODFAB := aLista[nContar,12]
             AA3->AA3_LOJAFA := aLista[nContar,13]
             AA3->AA3_STATUS := "01"
  	         MsUnlock()
  	      Endif   
	      
	   Else
	      
          // ######################################
          // Verifica quantos registros retornou ##
          // ######################################
          If T_SERIES->(RECNO()) > 1
             aLista[nContar,02] := "8"
             aLista[nContar,15] := "Foram encontrados mais do que 1 registro para o mesmo n� de s�ire."
             Loop
          Else
          
             // ##########################################################################
             // Verifica se o contrato � diferente do contrato do arquivo de importa��o ##          
             // ##########################################################################

             lTrocouCliente := .F. 
     
             If Empty(Alltrim(T_SERIES->AA3_CONTRT))
   
                // ############################
                // Registra o n� do contrato ##
                // ############################
                DBSelectArea("AA3")     
                DbSetOrder(1)
                If DbSeek( aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,06] + aLista[nContar,09] + aLista[nContar,11])

                   If kTipo == 0

       	              If T_SERIES->AA3_CODCLI <> aLista[nContar,05]
                         lTrocouCliente := .T. 
                      Endif

       	              If T_SERIES->AA3_LOJA <> aLista[nContar,06]
                         lTrocouCliente := .T. 
                      Endif
                   
                   Else

      	              RecLock("AA3",.F.)
                      AA3->AA3_CONTRT := aLista[nContar,08]
       	        
       	              If T_SERIES->AA3_CODCLI <> aLista[nContar,05]
                         lTrocouCliente := .T. 
                         AA3->AA3_CODCLI := aLista[nContar,05]
                      Endif

       	              If T_SERIES->AA3_LOJA <> aLista[nContar,06]
                         lTrocouCliente := .T. 
                         AA3->AA3_LOJA := aLista[nContar,06]
                      Endif
       	        
       	              MsUnlock()

       	           Endif   

                   If lTrocouCliente == .F.                     
                      aLista[nContar,02] := "5"
                      aLista[nContar,15] := "N� do contrato ser� atualizado." 
                   Else
                      aLista[nContar,02] := "5"
                      aLista[nContar,15] := "N� do contrato ser� atualizado e cliente ser� alterado." 
                   Endif                         

                   Loop
       	           
       	        Else
       	        
                   aLista[nContar,02] := "8"
       	           aLista[nContar,15] := "N�o ser� poss�vel atualizar o c�digo do contrato."
       	           Loop
       	        
       	        Endif
       	        
       	     Else
       	     
                If Alltrim(T_SERIES->AA3_CONTRT) <> Alltrim(T_SERIES->AA3_CONTRT)
                   aLista[nContar,02] := "8"
                   aLista[nContar,15] := "Registro possui contrato vinculado com outro c�digo de contrato (Contrato N� " + Alltrim(T_SERIES->AA3_CONTRT) + ")"
                   Loop
                Endif
       	     
       	     Endif
       	           
          Endif	           
          
       Endif   

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "" } )   
   Endif   

   If kTipo == 1
      aLista := {}
      aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "" } )        
      MsgAlert("Arquivo importado com sucesso.")
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

Return(.T.)