#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativa��o
#define SW_SHOW             5 // Mostra na posi��o mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posi��o anterior
#define SW_SHOWDEFAULT      10// Posi��o padr�o da aplica��o
#define SW_FORCEMINIMIZE    11// For�a minimiza��o independente da aplica��o executada
#define SW_MAX              11// Maximizada

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM592.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 06/07/2017                                                          ##
// Objetivo..: Programa importador de n�meros de s�ries da TERCA                   ##
// Par�metros: Sem Par�metros                                                      ##
// ##################################################################################

User Function AUTOM592()

   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   Private aBrowse   := {}
   Private aSeries   := {}
   Private aLista    := {}
   Private oLista

   Private kk_Nota   := ""
   Private kk_Serie  := ""

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

   U_AUTOM628("AUTOM592")

   DEFINE MSDIALOG oDlg TITLE "Endere�amento de N� de S�ries TERCA" FROM C(178),C(181) TO C(619),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
   @ C(206),C(245) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(206),C(290) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Arquivo a ser aberto"                 Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Conte�do do arquivo aberto"           Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(301) Say "N� de S�ries do registro selecionado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(258) Say "A Endere�ar"                          Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(207),C(304) Say "J� Endere�ado"                        Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(003) MsGet oGet1 Var cCaminho Size C(234),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(044),C(241) Button "..."                       Size C(016),C(009) PIXEL OF oDlg ACTION( PESQTERCA() )
   @ C(044),C(261) Button "Abrir"                     Size C(037),C(009) PIXEL OF oDlg ACTION( ImpNSBrowse() )
   @ C(044),C(301) Button "N� de S�ries"              Size C(087),C(009) PIXEL OF oDlg ACTION( VeNSeries() ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(005) Button "Marca Todos"               Size C(050),C(012) PIXEL OF oDlg ACTION( MrcNSeries(1) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(056) Button "Desmarca Todos"            Size C(050),C(012) PIXEL OF oDlg ACTION( MrcNSeries(0) ) When !Empty(Alltrim(aLista[01,03]))
   @ C(204),C(112) Button "Endere�ar"                 Size C(050),C(012) PIXEL OF oDlg ACTION( EnderecaNS() )
   @ C(204),C(166) Button "Endere�amento de Produtos" Size C(076),C(012) PIXEL OF oDlg ACTION( MATA265() )
   @ C(204),C(356) Button "Voltar"                    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // #################
   // Desenha aLista ##
   // #################
   aAdd( aLista, { .F., "2", "", "", "" } )

   @ 080,005 LISTBOX oLista FIELDS HEADER "M"                      ,; // 01  
                                          "LG"                     ,; // 02 
                                          "Produto"                ,; // 03
                                          "Descri��o dos Produtos" ,; // 04
                                          "Qtd N�s de S�ries"       ; // 05
                                          PIXEL SIZE 375,178 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         }}

   // ###################
   // Desenha o Browse ##
   // ###################
   aAdd( aBrowse, { "" } )

   oBrowse := TCBrowse():New( 080 , 385, 115, 178,,{'Arquivos' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################################
// Fun��o que abre di�logo de pesquisa dos arquivos a serem lidos ##
// #################################################################
Static Function PESQTERCA()

   cCaminho := cGetFile('*.csv', "Selecione o Arquivo de N� de S�ries",1,"C:\",.F.,16,.F.)

Return .T. 

// ############################################################
// Fun��o que mostra os n� de s�ries do registro selecionado ##
// ############################################################
Static Function VENSERIES()

   Local nContar := 0
   
   aBrowse := {}
   
   For nContar = 1 to Len(aSeries)
       If Upper(Alltrim(aSeries[nContar,03])) == Upper(Alltrim(aLista[oLista:nAt,03]))
          aAdd( aBrowse, { aSeries[nContar,05] } )
       Endif
   Next nContar        
      
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

Return(.T.)

// #########################################
// Fun��o que marca/desmarca os registros ##
// #########################################
Static Function MrcNSeries(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       If kTipo == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.                
       Endif         
   Next nContar
   
Return(.T.)       

// ######################################################
// Fun��o que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function ImpNSBrowse()

   MsgRun("Aguarde! Importando dados do arquivo selecionado ...", "Importa��o TERCA",{|| xImpNSBrowse() })

Return(.T.)

// ######################################################
// Fun��o que importa o arquivo selecionado na aBrowse ##
// ######################################################
Static Function xImpNSBrowse()

   Local nContar   := 0
   Local nPercorre := 0
   Local nLimpa    := 0
   Local lMarcadas := .F.
   Local cAgravar  := ""
   Local cConteudo := ""
   Local aCarga    := {}  
   Local aTempo    := {}
   Local nProcura  := 0
   Local lJaEsta   := .F.       
   
   // ################################################
   // Limpa o array aLimpa para receber novos dados ##
   // ################################################
   aLista := {}
   aTotal := {}

   // ########################################
   // Abre o arquivo selecionado na aBrowse ##
   // ########################################
   nHandle := FOPEN(Alltrim(cCaminho) + Alltrim(aBrowse[oBrowse:nAt,01]), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
      aprodutos := {}
      Return .T.
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
 
   cConteudo := ""

   For nPercorre = 1 to Len(xBuffer)

       If Substr(xBuffer, nPercorre, 1) <> CHR(10)
          cConteudo := cConteudo + Substr(xBuffer, nPercorre, 1)
       Else
          cConteudo := cConteudo + ";"
          aAdd( aCarga, { cConteudo } )
          cConteudo := ""
       Endif

   Next nPercorre

   // ##################################
   // Fecha a leitura do arquivo lido ##
   // ##################################
   FCLOSE(nHandle)

   // #######################################################
   // Carrega o array aBrowse pela leitura do array aCarga ##
   // #######################################################
   kInicio  := .F.
   kk_Nota  := ""
   kk_Serie := ""

   For nContar = 1 to Len(aCarga)

//       If (Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 1)) = "CODIGO EMPRESA")) .And.;
//          (Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 1) = "CODIGO"))
//          Loop
//       Endif

       If U_P_OCCURS(aCarga[nContar,01], "CODIGO", 1) <> 0
          Loop
       Endif

       aAdd( aSeries , { .F.                                              ,;
                         "2"                                              ,;
                         U_P_CORTA(aCarga[nContar,01], ";", 5) + Space(30),;
                         U_P_CORTA(aCarga[nContar,01], ";", 6) + Space(60),;                           
                         U_P_CORTA(aCarga[nContar,01], ";", 7)})

       // ###################################################################################
       // Verifica se o produto j� est� contido no array aLista. Se n�o estiver, o inclui. ##
       // ###################################################################################
       lJaEsta := .F.
       For nLocaliza = 1 to Len(aLista)
           If Upper(Alltrim(aLista[nLocaliza,03])) == Upper(Alltrim(U_P_CORTA(aCarga[nContar,01], ";", 5)))
              lJaEsta := .T.
              Exit
           Endif
       Next nLocaliza
       
       If lJaEsta == .T.
          aLista[nLocaliza,05] := aLista[nLocaliza,05] + 1       
       Else
          kk_Nota  := U_P_CORTA(aCarga[nContar,01], ";", 3)
          kk_Serie := U_P_CORTA(aCarga[nContar,01], ";", 4)
          aAdd( aLista , { .F.                                             ,;
                          "2"                                              ,;
                          U_P_CORTA(aCarga[nContar,01], ";", 5) + Space(30),;
                          U_P_CORTA(aCarga[nContar,01], ";", 6) + Space(60),;                           
                          1                                                })
       Endif

   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { .F., "2", "", "", "" })
   Endif
      
   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         }}

   // ###################################################################### 
   // Envia para a fun��o que mostra os n�s de s�ries do primeiro produto ##
   // ######################################################################
   If Empty(Alltrim(aLista[01,03]))
   Else
      VENSERIES()
   Endif   

Return(.T.)

// #######################################################
// Fun��o que realiza o endere�amento dos n�s de s�ries ##
// #######################################################
Static Function EnderecaNS()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local nContar  := 0
   Local lMarcado := .F.

   Private cNFAuto	 := kk_Nota
   Private cSRAuto	 := kk_Serie
   Private cNFForn	 := Space(09)
   Private cSRForn 	 := Space(03)
   Private cCodFor	 := Space(06)
   Private cLojFor	 := Space(03)
   Private cNomeFo	 := Space(60)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgEnder

   // ###################################################################
   // Verifica se houve pelo menos um registro marcado no array aLista ##
   // ###################################################################
   lMarcados := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T. 
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum n� de s�rie foi marcado para ser endere�ado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif

   // ####################################################################################################
   // Desenha a tela para solicitar o n� da nota fiscal do fornecedor para importa��o dos N�s de S�ries ##
   // ####################################################################################################
   DEFINE MSDIALOG oDlgEnder TITLE "Endere�amento N� S�rie" FROM C(178),C(181) TO C(426),C(554) PIXEL

   @ C(001),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(024) PIXEL NOBORDER OF oDlgEnder

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(179),C(001) PIXEL OF oDlgEnder
   @ C(101),C(002) GET oMemo2 Var cMemo2 MEMO Size C(179),C(001) PIXEL OF oDlgEnder
   
   @ C(033),C(005) Say "Importa��o ref a NF/S�rie Automatech" Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
   @ C(056),C(005) Say "N� NF/S�rie Fornecedor"               Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
   @ C(078),C(005) Say "Fornecedor/Loja"                      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgEnder
      
   @ C(043),C(005) MsGet oGet1 Var cNFAuto Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba
   @ C(043),C(041) MsGet oGet2 Var cSRAuto Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba
   @ C(066),C(005) MsGet oGet3 Var cNFForn Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder
   @ C(066),C(041) MsGet oGet4 Var cSRForn Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder
   @ C(087),C(005) MsGet oGet5 Var cCodFor Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder F3("SA2")
   @ C(087),C(041) MsGet oGet6 Var cLojFor Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder VALID( CCppFF() )
   @ C(087),C(060) MsGet oGet7 Var cNomeFo Size C(119),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgEnder When lChumba

   @ C(106),C(053) Button "Endere�ar" Size C(037),C(012) PIXEL OF oDlgEnder ACTION( xxEnderecaNS() )
   @ C(106),C(092) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgEnder ACTION( oDlgEnder:End() )

   ACTIVATE MSDIALOG oDlgEnder CENTERED 

Return(.T.)

// #####################################################
// Fun��o que pesquisa o nome do fornecedor informado ##
// #####################################################
Static Function CCppFF()

   If Empty(Alltrim(cCodFor))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cLojFor))
      Return(.T.)
   Endif

   cNomeFo := POSICIONE("SA2",1,XFILIAL("SA2") + cCodFor + cLojFor, "A2_NOME")
   
   If Empty(Alltrim(cNomeFo))
      cCodFor := Space(06)
      cLojFor := Space(03)
      cNomeFo := Space(60)
      oGet5:Refresh() 
      oGet6:Refresh() 
      oGet7:Refresh()       
      MsgAlert("Fornecedor informado n�o cadastrado. Verifique!")
      Return(.T.)
   Endif
      
Return(.T.)

// ###########################################
// Realiza o endere�amento dos n� de s�ries ##
// ###########################################
Static Function xxEnderecaNS()

   If Empty(Alltrim(cNFForn))
      MsgAlert("N� da nota fiscal do fornecedor n�o informada. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cSRForn))
      MsgAlert("N� de S�rie da nota fiscal do fornecedor n�o informada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCodFor)) .OR. Empty(Alltrim(cLojFor))
      MsgAlert("Necess�rio informar o Fornecedor. Verifique!")
      Return(.T.)
   Endif

   // ######################################################
   // In�cio do processo de endere�amento de n� de s�ries ##
   // ######################################################
   For nContar = 1 to Len(aLista)
   
       // ################################################
       // Se registro n�o estiver marcado, l� o pr�ximo ##
       // ################################################
       If aLista[nContar,01] == .F.
          Loop
       Endif
       
       // #########################################################################################
       // Verirfica se existe endere�amento pendente para a Nota Fical/S�rie/Produto selecionado ##
       // #########################################################################################
       If Select("T_PENDENTE") > 0
          T_PENDENTE->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT DA_FILIAL ,"
       cSql += "       DA_PRODUTO," 
	   cSql += "       DA_QTDORI ,"
	   cSql += "       DA_SALDO  ,"
	   cSql += "       DA_DATA   ,"
	   cSql += "       DA_LOCAL  ,"
	   cSql += "       DA_DOC    ,"
	   cSql += "       DA_SERIE  ,"
	   cSql += "       DA_CLIFOR ,"
	   cSql += "       DA_LOJA   ,"
	   cSql += "       DA_TIPONF ,"
	   cSql += "       DA_NUMSEQ ,"
	   cSql += "       DA_ORIGEM  "
       cSql += "  FROM " + RetSqlName("SDA")
       cSql += " WHERE DA_FILIAL  = '" + Alltrim(cFilAnt) + "'"
       cSql += "   AND DA_DOC     = '" + Alltrim(cNFForn) + "'"
       cSql += "   AND DA_SERIE   = '" + Alltrim(cSRForn) + "'"
       cSql += "   AND DA_CLIFOR  = '" + Alltrim(cCodFor) + "'"
       cSql += "   AND DA_LOJA    = '" + Alltrim(cLojFor) + "'"
       cSql += "   AND DA_PRODUTO = '" + Alltrim(Strzero(Int(Val(aLista[nContar,03])),6)) + "'"
       cSql += "   AND DA_QTDORI  = DA_SALDO"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PENDENTE", .T., .T. )
       
       If T_PENDENTE->( EOF() )
          MsgAlert("Aten��o!"                                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "N�o existe pendencia de endere�amento para o produto "           + chr(13) + chr(10)                     + ;
                   Alltrim(aLista[nContar,03]) + " - " + Alltrim(aLista[nContar,04]) + chr(13) + chr(10)                     + ;
                   "ou produto j� foi endere�ado."                                   + chr(13) + chr(10)                     + ;
                   "Verifique a informa��o do n� da nota fiscal/ s�rie do fornecedor se est�o corretas.")
          Return(.T.)
       Endif
                             
       // ######################################################
       // Lan�a dos Endere�amentos para o produto selecionado ##
       // ######################################################

       nSeqItem := 0       

       For nEndereco = 1 to Len(aSeries)

           If Upper(Alltrim(Strzero(Int(Val(aSeries[nEndereco,03])),6))) == Upper(Alltrim(Strzero(Int(Val(aLista[nContar,03])),6)))
           
              nSeqItem += 1

     		  DbSelectArea("SDB")
		      Reclock("SDB",.T.)
              SDB->DB_FILIAL  := T_PENDENTE->DA_FILIAL
              SDB->DB_ITEM    := Strzero(nSeqItem,4)
              SDB->DB_PRODUTO := Strzero(Int(Val(aLista[nContar,03])),6) + Space(24)
              SDB->DB_LOCAL   := T_PENDENTE->DA_LOCAL
              SDB->DB_LOCALIZ := "GENERICO"
              SDB->DB_DOC     := T_PENDENTE->DA_DOC
              SDB->DB_SERIE   := T_PENDENTE->DA_SERIE
              SDB->DB_CLIFOR  := T_PENDENTE->DA_CLIFOR
              SDB->DB_LOJA    := T_PENDENTE->DA_LOJA
              SDB->DB_TIPONF  := T_PENDENTE->DA_TIPONF
              SDB->DB_TM      := "499"
              SDB->DB_ORIGEM  := T_PENDENTE->DA_ORIGEM
              SDB->DB_QUANT   := 1
              SDB->DB_DATA    := DATE()
              SDB->DB_NUMSERI := aSeries[nEndereco,05]
              SDB->DB_NUMSEQ  := T_PENDENTE->DA_NUMSEQ
              SDB->DB_TIPO    := "D"
              SDB->DB_SERVIC  := "499"
              SDB->DB_ATIVID  := "ZZZ"
              SDB->DB_HRINI   := TIME()
              SDB->DB_ATUEST  := "S"
              SDB->DB_STATUS  := "M"
              SDB->DB_ORDATIV := "ZZ"
     		  MsUnlock()

     		  DbSelectArea("SBF")
		      Reclock("SBF",.T.)
		      SBF->BF_FILIAL  := T_PENDENTE->DA_FILIAL
		      SBF->BF_PRODUTO := Strzero(Int(Val(aLista[nContar,03])),6) + Space(24)
		      SBF->BF_LOCAL   := T_PENDENTE->DA_LOCAL
		      SBF->BF_LOCALIZ := "GENERICO" 
		      SBF->BF_NUMSERI := aSeries[nEndereco,05] 
		      SBF->BF_QUANT   := 1 
     		  MsUnlock()
     		  
           Endif

       Next nEndereco

       // #####################################################
       // Zera o saldo para n�o precisar endere�ar novamente ##
       // #####################################################
       dbSelectArea("SDA")
	   dbSetOrder(1)
	   If DbSeek(T_PENDENTE->DA_FILIAL + T_PENDENTE->DA_PRODUTO + T_PENDENTE->DA_LOCAL + T_PENDENTE->DA_NUMSEQ + T_PENDENTE->DA_DOC + T_PENDENTE->DA_SERIE + T_PENDENTE->DA_CLIFOR + T_PENDENTE->DA_LOJA)
          Reclock("SDA",.F.)
          SDA->DA_SALDO := 0
   		  MsUnlock()          
   	   Endif

       // #######################################################
       // Subtrai do campo B2_QACLASS (Quantidade a Endere�ar) ##
       // #######################################################
       dbSelectArea("SB2")
	   dbSetOrder(1)
	   If DbSeek(T_PENDENTE->DA_FILIAL + T_PENDENTE->DA_PRODUTO + T_PENDENTE->DA_LOCAL)
          Reclock("SB2",.F.)
          SB2->B2_QACLASS := SB2->B2_QACLASS - aLista[nContar,05]
   		  MsUnlock()          
   	   Endif


       // #################################
       // Altera o Status para importado ##
       // #################################
       aLista[nContar,02] := "8"       

   Next nContar        

   MsgAlert("Importa��o realizada com sucesso.")
   
   oDlgEnder:End() 

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, ""))))))))),;                         
                           aLista[oLista:nAt,03]         ,;
                           aLista[oLista:nAt,04]         ,;
                           aLista[oLista:nAt,05]         }}
   
Return(.T.)

// ###########################
// Layout do Arquivo TERCA  ##
// ###########################
// 1� Layout da TERCA       ##
//                          ##
// 1 - C�digo Empresa       ##
// 2 - C�digo Produto       ##
// 3 - Descri��o Produto    ##
// 4 - N�mero S�rie         ##
// 5 - Classe               ##
// 6 - NF Remessa           ##
// 7 - Serie                ##
//                          ##
// 2� Layout da TERCA       ##
//                          ##
// 1 - Codigo Empresa       ##
// 2 - Depositante          ##
// 3 - Documento            ##
// 4 - Serie                ##
// 5 - C�digo produto       ##
// 6 - S�rie                ##
// 7 - N�mero S�rie         ##
// 8 - Status               ##
// ###########################

