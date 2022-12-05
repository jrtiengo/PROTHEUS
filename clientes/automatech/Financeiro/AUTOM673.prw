#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
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
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM673.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ## 
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 26/01/2018                                                            ##
// Objetivo..: Programa que integra o Simfrete X Contas a Pagar                      ##
// #################################################################################### 

User Function AUTOM673()

   MsgRun("Aguarde! Abrindo o Integrador SimFrete X Protheus (SCP) ...", "Programa: AUTOM673",{|| XAUTOM673() })

Return(.T.)

// ####################################################################
// Função que abre a tela do integrador do Simfrete X Protheus (SCP) ##
// ####################################################################
Static Function XAUTOM673()

   Local lChumba     := .F.
   Local cMemo1	     := ""
   Local oMemo1
   
   Private lMontar   := .T.

   Private aEmpresas := U_AUTOM539(1, "")      
   Private aFiliais  := U_AUTOM539(2, cEmpAnt) 
   Private aTipoData := {"1 - Importação", "2 - Emissão", "3 - Autorização", "4 - Vencimento"}
   Private aStatus   := {"0 - Todos", "1 - Liberados P/Pgtº", "2 - Cancelados", "3 - Lançados Protheus", "4 - Fatura Gerada", "5 - Transp.Inexistente"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private cInicial    := Ctod("  /  /    ")
   Private cFinal 	   := Ctod("  /  /    ")
   Private cTransporte := Space(06)
   Private cNomeTran   := Space(60)
   Private cFatura     := Space(20)
   Private nTotalPsq   := 0
   Private nTotalFat   := 0
   Private nTotalSel   := 0
   Private nDiferenca  := 0
   Private nVenctFat   := Ctod("  /  /    ")
   Private lRaiz       := .F.
   Private cLocaliza   := Space(20)
   
   Private aFatura     := {}

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7   
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12   
   Private oGet14   
   Private oCheckBox1
   
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

   // ######################################
   // Posiciona o combo da Empresa Logada ##
   // ######################################
   Do Case
      Case cEmpAnt == "01" 
           cComboBx1 := "01 - AUTOMATECH"
      Case cEmpAnt == "02" 
           cComboBx1 := "02 - TI AUTOMAÇÃO"
      Case cEmpAnt == "03" 
           cComboBx1 := "03 - ATECH"
      Case cEmpAnt == "04" 
           cComboBx1 := "04 - ATECHPEL"
   EndCase

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Consulta Conhecimentos de Transportes (CTE-s)" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"            Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(053) Say "Filial"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(101) Say "Data Inicial"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(142) Say "Data Final"         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(183) Say "Tipo Data"          Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(226) Say "Nº Fatura"          Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(272) Say "Status"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(316) Say "Transportadora"     Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(005) Say "Nº da Farura"       Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(061) Say "Vencimento Fatura"  Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(117) Say "Total da Fatura"    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(183) Say "Total da Pesquisa"  Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(239) Say "Total Selecionados" Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(295) Say "Diferença"          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(187),C(364) Say "Localizar CTE's"    Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1  Items aEmpresas   Size C(045),C(010)                                         PIXEL OF oDlg When lChumba // ON CHANGE AlteraCombo()
   @ C(045),C(053) ComboBox cComboBx2  Items aFiliais    Size C(045),C(010)                                         PIXEL OF oDlg
   @ C(045),C(101) MsGet    oGet1      Var   cInicial    Size C(037),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(045),C(142) MsGet    oGet2      Var   cFinal      Size C(037),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(045),C(183) ComboBox cComboBx3  Items aTipoData   Size C(041),C(010)                                         PIXEL OF oDlg
   @ C(045),C(226) MsGet    oGet5      Var   cFatura     Size C(042),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg
   @ C(045),C(272) ComboBox cComboBx4  Items aStatus     Size C(042),C(010)                                         PIXEL OF oDlg
   @ C(036),C(347) CheckBox oCheckBox1 Var   lRaiz       Prompt "Pesquisar transportadoras pelo raiz do CNPJ" Size C(116),C(008) PIXEL OF oDlg
   @ C(045),C(316) MsGet    oGet3      Var   cTransporte Size C(027),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg F3("SA4") VALID( cNomeTran := POSICIONE("SA4",1,XFILIAL("SA4") + cTransporte,"A4_NOME") )
   @ C(045),C(347) MsGet    oGet4      Var   cNomeTran   Size C(112),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(195),C(005) MsGet    oGet8      Var   cFatura     Size C(050),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(195),C(061) MsGet    oGet9      Var   nVenctFat   Size C(050),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(195),C(117) MsGet    oGet10     Var   nTotalFat   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(183) MsGet    oGet11     Var   nTotalPsq   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(239) MsGet    oGet12     Var   nTotalSel   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(295) MsGet    oGet13     Var   nDiferenca  Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(364) MsGet    oGet14     Var   cLocaliza   Size C(093),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When !Empty(Alltrim(aLista[01,04]))

   @ C(043),C(461) Button "Pesquisar"      Size C(037),C(012) PIXEL OF oDlg ACTION( PesquisaLista(1) )
// @ C(050),C(461) Button "Monta Fat."     Size C(037),C(009) PIXEL OF oDlg ACTION( PesquisaLista(2) )
   @ C(210),C(005) Button "Marcar Todos"   Size C(045),C(012) PIXEL OF oDlg ACTION( MrcCTE(1) )            When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(051) Button "Desmarca Todos" Size C(045),C(012) PIXEL OF oDlg ACTION( MrcCTE(2) )            When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(097) Button "Detalhes"       Size C(037),C(012) PIXEL OF oDlg ACTION( MostraDetalhe(0,0) )   When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(135) Button "Importar"       Size C(037),C(012) PIXEL OF oDlg ACTION( BuscaConhecimentos() )
   @ C(210),C(174) Button "Excel"          Size C(037),C(012) PIXEL OF oDlg ACTION( Carregaexcel() )       When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(212) Button "Legendas"       Size C(037),C(012) PIXEL OF oDlg ACTION( Mostraleg() ) 
   @ C(210),C(250) Button "Gera Doc."      Size C(037),C(012) PIXEL OF oDlg ACTION( GeraDocEnt() )         When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(288) Button "Doc.Ent."       Size C(037),C(012) PIXEL OF oDlg ACTION( MATA103() )
   @ C(210),C(326) Button "Vinc. Fatura"   Size C(037),C(012) PIXEL OF oDlg ACTION( VINCULAFATURA() )      When !Empty(Alltrim(aLista[01,04]))

// @ C(210),C(364) Button "Montar Fatura"  Size C(037),C(012) PIXEL OF oDlg ACTION( PesquisaLista(2) )     When lMontar  // ACTION( GeraFatura() )
// @ C(210),C(402) Button "Gerar Fatura"   Size C(037),C(012) PIXEL OF oDlg ACTION( GeraFatura() )         When !lMontar

   @ C(210),C(364) Button "Gerar Fatura"   Size C(037),C(012) PIXEL OF oDlg ACTION( PesquisaLista(2) )     When !Empty(Alltrim(aLista[01,04]))

   @ C(195),C(461) Button "Localizar"      Size C(037),C(012) PIXEL OF oDlg ACTION( LocCTEReg() )          When !Empty(Alltrim(aLista[01,04]))
   @ C(210),C(461) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "0", "1", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   @ 080,005 LISTBOX oList FIELDS HEADER "Mrc"                                    ,; // 01 
                                         "Leg"                                    ,; // 02
                                         "CNPJ Transportadora"                    ,; // 03
                                         "Descrição Transportadoras"              ,; // 04
                                         "CNPJ Remetente"                         ,; // 05
                                         "Descrição Remetentes NF"                ,; // 06
                                         "Emissão CT-e"                           ,; // 07
                                         "Valor Autorizado"                       ,; // 08
                                         "Cidade Origem"                          ,; // 09
                                         "Cidade Destino"                         ,; // 10
                                         "CFOP"                                   ,; // 11
                                         "Tp Frete"                               ,; // 12
                                         "Base ICMS"                              ,; // 13
                                         "% ICMS"                                 ,; // 14
                                         "Valor ICMS"                             ,; // 15
                                         "Cod.Fis.ICMS"                           ,; // 16
                                         "Sit. CT-e"                              ,; // 17
                                         "Chave CT-e"                             ,; // 18
                                         "Nº CT-e"                                ,; // 19
                                         "Nº Fatura"                              ,; // 20
                                         "Autorizado por"                         ,; // 21
                                         "Autorizado em"                          ,; // 22
                                         "Chave NF-e"                             ,; // 23
                                         "CNPJ Pagador Frete"                     ,; // 24
                                         "Dif. Valor Aut. X CT-e"                 ,; // 25
                                         "Dif. Valor Aut. X Valor Cobrado Fatura" ,; // 26
                                         "Valor da Fatura"                        ,; // 27
                                         "Simples Nacional"                       ,; // 28
                                         "Tipo Operação"                          ,; // 29
                                         "Base ISSQN"                             ,; // 30
                                         "% ISSQN"                                ,; // 31
                                         "Valor do ISSQN"                         ,; // 32
                                         "Código GISS"                            ,; // 33
                                         "Vencimento do CT-e"                     ,; // 34
                                         "Nr Doc. Entrada"                        ,; // 35
                                         "Série"                                  ,; // 36
                                         "Empresa"                                ,; // 37
                                         "Filial"                                 ,; // 38
                                         "Nº do CTE"                               ; // 39
                                         PIXEL SIZE 633,157 OF oDlg ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;          					             					   
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14],;
         	        	       aLista[oList:nAt,15],;
         	        	       aLista[oList:nAt,16],;
         	        	       aLista[oList:nAt,17],;
         	        	       aLista[oList:nAt,18],;
         	        	       aLista[oList:nAt,19],;
         	        	       aLista[oList:nAt,20],;
         	        	       aLista[oList:nAt,21],;
         	        	       aLista[oList:nAt,22],;
         	        	       aLista[oList:nAt,23],;
         	        	       aLista[oList:nAt,24],;         	        	       
         	        	       aLista[oList:nAt,25],;
         	        	       aLista[oList:nAt,26],;
         	        	       aLista[oList:nAt,27],;
         	        	       aLista[oList:nAt,28],;
         	        	       aLista[oList:nAt,29],;
         	        	       aLista[oList:nAt,30],;
         	        	       aLista[oList:nAt,31],;
         	        	       aLista[oList:nAt,32],;
         	        	       aLista[oList:nAt,33],;
         	        	       aLista[oList:nAt,34],;
         	        	       aLista[oList:nAt,35],;
         	        	       aLista[oList:nAt,36],;
         	        	       aLista[oList:nAt,37],;
        	        	       aLista[oList:nAt,38],;
        	        	       aLista[oList:nAt,39]}}

   oList:bLDblClick := {|| MarcaIndi() } 

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ######################################
// Função que localiza o cte informado ##
// ######################################
Static Function LocCTEReg()

   Local nContar   := 0
   Local lAcheiCTE := .F.

   If Empty(Alltrim(cLocaliza))
      MsgAlert("Nenhum nº de CTE foi informado para localização. Verifique!")
      Return(.T.)
   Endif   

   lAcheiCTE := .F.   

   For nContar = 1 to Len(aLista)
   
       kDocumento  := Strzero(INT(VAL(Substr(aLista[nContar,18],26,09))),9)       
       
       If U_P_OCCURS(kDocumento, cLocaliza, 1) == 0
       Else
          
          lAcheiCTE := .T.
         
          If MsgYesNo("CTE Localizado."                            + chr(13) + chr(10) + chr(13) + chr(10) + ;
                      "Este CTE será selecionado automaticamente." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                      "Deseja visualizar detalhes deste CTE?")
             MostraDetalhe(1, nContar)
             aLista[nContar,01] := .T.
             Exit
          Else
             aLista[nContar,01] := .T.
             Exit          
          Endif
          
       Endif      

   Next nContar

   If lAcheiCTE == .F.
      MsgAlert("CTE informado não localizado.")
   Endif         
   
   cLocaliza := Space(20)
   oGet14:Refresh()
   
Return(.T.)      

// ##########################################
// Função que marca o registro posicionado ##
// ##########################################
Static Function Marcaindi()

   If aLista[oList:nAt,01] == .F.
      aLista[oList:nAt,01] := .T.
   Else
      aLista[oList:nAt,01] := .F.
   Endif

   TotalizaTela()   

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(045),C(053) ComboBox cComboBx2 Items aFiliais Size C(045),C(010) PIXEL OF oDlg

Return(.T.)

// #####################################################################
// Função que marca e desmarca as ordens de serviço para distribuição ##
// #####################################################################
Static Function MrcCTE(_Botao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)

       If Empty(Alltrim(aLista[nContar,03]))
          Loop
       Endif
       If _Botao == 1
          If aLista[nContar,02] == "2" .Or. aLista[nContar,02] == "1"
             aLista[nContar,01] := .T.
          Else
             aLista[nContar,01] := .F.
          Endif      
       Else
          aLista[nContar,01] := .F.
       Endif
   Next nContar       

   oList:Refresh()

   TotalizaTela()   
   
Return(.T.)

// ###############################################
// Função que mostra o significado das legendas ##
// ###############################################
Static Function Mostraleg()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2
 
   Private oDlgLeg

   DEFINE MSDIALOG oDlgLeg TITLE "Integração Simfrete X Contas a Pagar" FROM C(178),C(181) TO C(460),C(541) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgLeg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(174),C(001) PIXEL OF oDlgLeg
   @ C(119),C(002) GET oMemo2 Var cMemo2 MEMO Size C(170),C(001) PIXEL OF oDlgLeg
   
   @ C(039),C(005) Jpeg FILE "br_verde"    Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg
   @ C(052),C(005) Jpeg FILE "br_cancel"   Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg
   @ C(065),C(005) Jpeg FILE "br_vermelho" Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg
   @ C(078),C(005) Jpeg FILE "br_amarelo"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg
   @ C(091),C(005) Jpeg FILE "br_azul"     Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg
   @ C(104),C(005) Jpeg FILE "br_preto"    Size C(009),C(009) PIXEL NOBORDER OF oDlgLeg

   @ C(041),C(020) Say "CTE liberados para inclusão Documento de Entrada"             Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg
   @ C(054),C(020) Say "CTE não autorizado mas pode ser gerado Documento de Entrada " Size C(156),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg
   @ C(067),C(020) Say "CTE Cancelados"                                               Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg
   @ C(080),C(020) Say "CTE Processados. Aguardando Liberação"                        Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg
   @ C(093),C(021) Say "CTE Finalizados (Doc de Entrada Gerado)"                      Size C(103),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg
   @ C(106),C(021) Say "Transportadora não cadastrada como fornecedor"                Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlgLeg

   @ C(124),C(070) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLeg ACTION( oDlgLeg:End() )

   ACTIVATE MSDIALOG oDlgLeg CENTERED 

Return(.T.)

// ###############################################
// Função que mostra o significado das legendas ##
// ###############################################
Static Function MostraDetalhe(kTipo, nPosicao)

   MsgRun("Aguarde! Abrindo detalhes do CTE ...", "Detalhe do CTE",{|| xMostraDetalhe(kTipo, nPosicao) })

Return(.T.)

// ######################################################
// Função que mostra o detalhe do regsitro selecionado ##
// ######################################################
Static Function xMostraDetalhe(kTipo, nPosicao)

   Local cString := ""
   Local cMemo1	 := ""
   Local oMemo1

   Local oFont18 := TFont():New( "Couruer New",,18,,.F.,,,,,.F. )

   Private oDlg

   If kTipo == 0
      cString := ""
      cString := cString + "CNPJ Transportadora....................: " + aLista[oList:nAt,03] + CHR(13) + CHR(10)
      cString := cString + "Nome da Transportadora.................: " + aLista[oList:nAt,04] + CHR(13) + CHR(10)
      cString := cString + "CNPJ Remetente.........................: " + aLista[oList:nAt,05] + CHR(13) + CHR(10)
      cString := cString + "Nome do Remetente......................: " + aLista[oList:nAt,06] + CHR(13) + CHR(10)
      cString := cString + "Emissão CT-e...........................: " + aLista[oList:nAt,07] + CHR(13) + CHR(10)
      cString := cString + "Valor Autorizado.......................: " + Transform(aLista[oList:nAt,08], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Cidade Origem..........................: " + aLista[oList:nAt,09] + CHR(13) + CHR(10)
      cString := cString + "Cidade Destino.........................: " + aLista[oList:nAt,10] + CHR(13) + CHR(10)
      cString := cString + "CFOP...................................: " + aLista[oList:nAt,11] + CHR(13) + CHR(10)
      cString := cString + "Pago ou A Pagar (CIF/FOB)..............: " + aLista[oList:nAt,12] + CHR(13) + CHR(10)
      cString := cString + "Base ICMS..............................: " + Transform(aLista[oList:nAt,13], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "% ICMS.................................: " + Transform(aLista[oList:nAt,14], "@E 999.99")     + CHR(13) + CHR(10)
      cString := cString + "Valor ICMS.............................: " + Transform(aLista[oList:nAt,15], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Cod.Fis.ICMS...........................: " + aLista[oList:nAt,16] + CHR(13) + CHR(10)
      cString := cString + "Sit. CT-e..............................: " + aLista[oList:nAt,17] + CHR(13) + CHR(10)
      cString := cString + "Chave CT-e.............................: " + aLista[oList:nAt,18] + CHR(13) + CHR(10)
      cString := cString + "Nº CT-e................................: " + aLista[oList:nAt,19] + CHR(13) + CHR(10)
      cString := cString + "Nº Fatura..............................: " + aLista[oList:nAt,20] + CHR(13) + CHR(10)
      cString := cString + "Autorizado por.........................: " + aLista[oList:nAt,21] + CHR(13) + CHR(10)
      cString := cString + "Autorizado em..........................: " + aLista[oList:nAt,22] + CHR(13) + CHR(10)
      cString := cString + "Chave NF-e.............................: " + aLista[oList:nAt,23] + CHR(13) + CHR(10)
      cString := cString + "CNPJ Pagador Frete.....................: " + aLista[oList:nAt,24] + CHR(13) + CHR(10)
      cString := cString + "Dif. Valor Aut. X CT-e.................: " + Transform(aLista[oList:nAt,25], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Dif. Valor Aut. X Valor Cobrado Fatura.: " + Transform(aLista[oList:nAt,26], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Valor da Fatura........................: " + Transform(aLista[oList:nAt,27], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Simples Nacional.......................: " + aLista[oList:nAt,28] + CHR(13) + CHR(10)
      cString := cString + "Tipo Operação..........................: " + aLista[oList:nAt,29] + CHR(13) + CHR(10)
      cString := cString + "Base ISSQN.............................: " + Transform(aLista[oList:nAt,30], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "% ISSQN................................: " + Transform(aLista[oList:nAt,31], "@E 999.99")     + CHR(13) + CHR(10)
      cString := cString + "Valor do ISSQN.........................: " + Transform(aLista[oList:nAt,32], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Código GISS............................: " + aLista[oList:nAt,33] + CHR(13) + CHR(10)
      cString := cString + "Vencimento do CT-e.....................: " + aLista[oList:nAt,34] + CHR(13) + CHR(10)
      cString := cString + "Nr. Doc. Entrada.......................: " + aLista[oList:nAt,35] + CHR(13) + CHR(10)
      cString := cString + "Série..................................: " + aLista[oList:nAt,36] + CHR(13) + CHR(10)
      cString := cString + "Empresa................................: " + aLista[oList:nAt,37] + CHR(13) + CHR(10)
      cString := cString + "Filial.................................: " + aLista[oList:nAt,38] + CHR(13) + CHR(10)
      cString := cString + "Nº do CTE..............................: " + aLista[oList:nAt,39] + CHR(13) + CHR(10)
   Else
      cString := ""
      cString := cString + "CNPJ Transportadora....................: " + aLista[nPosicao,03] + CHR(13) + CHR(10)
      cString := cString + "Nome da Transportadora.................: " + aLista[nPosicao,04] + CHR(13) + CHR(10)
      cString := cString + "CNPJ Remetente.........................: " + aLista[nPosicao,05] + CHR(13) + CHR(10)
      cString := cString + "Nome do Remetente......................: " + aLista[nPosicao,06] + CHR(13) + CHR(10)
      cString := cString + "Emissão CT-e...........................: " + aLista[nPosicao,07] + CHR(13) + CHR(10)
      cString := cString + "Valor Autorizado.......................: " + Transform(aLista[nPosicao,08], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Cidade Origem..........................: " + aLista[nPosicao,09] + CHR(13) + CHR(10)
      cString := cString + "Cidade Destino.........................: " + aLista[nPosicao,10] + CHR(13) + CHR(10)
      cString := cString + "CFOP...................................: " + aLista[nPosicao,11] + CHR(13) + CHR(10)
      cString := cString + "Pago ou A Pagar (CIF/FOB)..............: " + aLista[nPosicao,12] + CHR(13) + CHR(10)
      cString := cString + "Base ICMS..............................: " + Transform(aLista[nPosicao,13], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "% ICMS.................................: " + Transform(aLista[nPosicao,14], "@E 999.99")     + CHR(13) + CHR(10)
      cString := cString + "Valor ICMS.............................: " + Transform(aLista[nPosicao,15], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Cod.Fis.ICMS...........................: " + aLista[nPosicao,16] + CHR(13) + CHR(10)
      cString := cString + "Sit. CT-e..............................: " + aLista[nPosicao,17] + CHR(13) + CHR(10)
      cString := cString + "Chave CT-e.............................: " + aLista[nPosicao,18] + CHR(13) + CHR(10)
      cString := cString + "Nº CT-e................................: " + aLista[nPosicao,19] + CHR(13) + CHR(10)
      cString := cString + "Nº Fatura..............................: " + aLista[nPosicao,20] + CHR(13) + CHR(10)
      cString := cString + "Autorizado por.........................: " + aLista[nPosicao,21] + CHR(13) + CHR(10)
      cString := cString + "Autorizado em..........................: " + aLista[nPosicao,22] + CHR(13) + CHR(10)
      cString := cString + "Chave NF-e.............................: " + aLista[nPosicao,23] + CHR(13) + CHR(10)
      cString := cString + "CNPJ Pagador Frete.....................: " + aLista[nPosicao,24] + CHR(13) + CHR(10)
      cString := cString + "Dif. Valor Aut. X CT-e.................: " + Transform(aLista[nPosicao,25], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Dif. Valor Aut. X Valor Cobrado Fatura.: " + Transform(aLista[nPosicao,26], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Valor da Fatura........................: " + Transform(aLista[nPosicao,27], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Simples Nacional.......................: " + aLista[nPosicao,28] + CHR(13) + CHR(10)
      cString := cString + "Tipo Operação..........................: " + aLista[nPosicao,29] + CHR(13) + CHR(10)
      cString := cString + "Base ISSQN.............................: " + Transform(aLista[nPosicao,30], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "% ISSQN................................: " + Transform(aLista[nPosicao,31], "@E 999.99")     + CHR(13) + CHR(10)
      cString := cString + "Valor do ISSQN.........................: " + Transform(aLista[nPosicao,32], "@E 9999999.99") + CHR(13) + CHR(10)
      cString := cString + "Código GISS............................: " + aLista[nPosicao,33] + CHR(13) + CHR(10)
      cString := cString + "Vencimento do CT-e.....................: " + aLista[nPosicao,34] + CHR(13) + CHR(10)
      cString := cString + "Nr. Doc. Entrada.......................: " + aLista[nPosicao,35] + CHR(13) + CHR(10)
      cString := cString + "Série..................................: " + aLista[nPosicao,36] + CHR(13) + CHR(10)
      cString := cString + "Empresa................................: " + aLista[nPosicao,37] + CHR(13) + CHR(10)
      cString := cString + "Filial.................................: " + aLista[nPosicao,38] + CHR(13) + CHR(10)
      cString := cString + "Nº do CTE..............................: " + aLista[nPosicao,39] + CHR(13) + CHR(10)
      
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Integrar Simfrete X Contas a Pagar" FROM C(178),C(181) TO C(601),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(005) GET oMemo1 Var cString MEMO Size C(383),C(162) Font oFont18 PIXEL OF oDlg

   @ C(196),C(178) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ################################################################
// Função que realiza a consulta de conhecimentos (Web Services) ##
// ################################################################
Static Function BuscaConhecimentos()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kInicial := Ctod("  /  /    ")
   Private kFinal   := Ctod("  /  /    ")
   Private kTranspo := Space(06)
   Private kNomeTra := Space(60)
   Private kCNPJ    := Space(14)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgCON

   DEFINE MSDIALOG oDlgCON TITLE "Consulta Conhecimentos de Transportes (CTE-s)" FROM C(178),C(181) TO C(387),C(575) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlgCON

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(191),C(001) PIXEL OF oDlgCON
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(191),C(001) PIXEL OF oDlgCON

   @ C(033),C(005) Say "Data Inicial"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON
   @ C(033),C(046) Say "Data Final"     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON
   @ C(055),C(005) Say "Transportadora" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgCON
   
   @ C(042),C(005) MsGet oGet1 Var kInicial Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCON
   @ C(042),C(046) MsGet oGet2 Var kFinal   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCON
   @ C(065),C(005) MsGet oGet3 Var kTranspo Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCON F3("SA4") VALID( PegaTran() )
   @ C(065),C(036) MsGet oGet4 Var kNomeTra Size C(157),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCON When lChumba

   @ C(086),C(060) Button "Consultar" Size C(037),C(012) PIXEL OF oDlgCON ACTION( ImpCTES() )
   @ C(086),C(098) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgCON ACTION( oDlgCON:End() )

   ACTIVATE MSDIALOG oDlgCON CENTERED 

Return(.T.)

// ########################################################
// Função que pesquisa a transportadora a ser consultada ##
// ########################################################
Static Function PegaTran()

   If Empty(Alltrim(kTranspo))
      kNomeTra := Space(60)
      Return(.T.)
   Endif

   kNomeTra := POSICIONE("SA4",1,XFILIAL("SA4") + kTranspo,"A4_NOME")
   kCNPJ    := POSICIONE("SA4",1,XFILIAL("SA4") + kTranspo,"A4_CGC" )
   
   If Empty(Alltrim(kNomeTra))
      kTranspo := Space(06)
      kNomeTra := Space(60)
      kCNPJ    := Space(14)
   Endif
   
Return(.T.)

// #########################################################
// Função que pesquisa os CTEs conforme período informado ##
// #########################################################
Static Function ImpCTES()

   Local cComando           := ""
   Local cURLSimFrete       := Space(250)
   Local cEmpresaSimFrete   := Space(050)
   Local cLoginSimFrete     := Space(020)
   Local cSenhaSimfrete     := Space(020)
   Local cEmailSimFrete     := Space(250)
   Local cCaminhoRetorno    := Space(250)
   Local cSTIM              := 500000

   Private cCaminhoRetorno  := Space(250)
   Private cRetorno         := Space(250)

   // #################################################
   // Consiste os dados antes de realizar a consulta ##
   // #################################################
   If kInicial == Ctod("  /  /    ")
      MsgAlert("Data Inicial de consulta não informada. Verifique!")
      Return(.T.)
   Endif   
                                   
   If kFinal == Ctod("  /  /    ")
      MsgAlert("Data Final de consulta não informada. Verifique!")
      Return(.T.)
   Endif   

   If Empty(Alltrim(kCNPJ))
   Else
      If (kFinal - kInicial) > 90
         MsgAlert("Intervalo de data não pode ser superior a 90 dias. Verifique!")
         Return(.T.)
      Endif   
   Endif   
   
   // ################################################################# 
   // Pesquisa os parâmetros para consumo do web service do SimFrete ##
   // #################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_SFRE)) AS SIMFRETE"    
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Parâmetros do SimFrete não definidos." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   cURLSimFrete     := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 1)))
   cEmpresaSimFrete := IIF(T_PARAMETROS->( EOF() ), Space(050), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2))), Space(050), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 2)))
   cLoginSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 3)))
   cSenhaSimfrete   := IIF(T_PARAMETROS->( EOF() ), Space(020), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4))), Space(020), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 4)))
   cEmailSimFrete   := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 5)))
   cCaminhoRetorno  := IIF(T_PARAMETROS->( EOF() ), Space(250), IIF(Empty(Alltrim(U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6))), Space(250), U_P_CORTA(T_PARAMETROS->SIMFRETE, "|", 6)))

   If Empty(Alltrim(cURLSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "URL do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif
            
   If Empty(Alltrim(cEmpresaSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Empresa de pesquisa do Web Service do Sim Frete não parametrizada." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cLoginSimFrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Login de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cSenhaSimfrete))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Senha de pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCaminhoRetorno))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Caminho para gravação retorno da pesquisa do Web Service do Sim Frete não parametrizado." + chr(13) + chr(10) + "Entre em contato com o Administrador do Sistema informando esta mensagem.")
      Return(.T.)
   Endif

   // ######################################################################
   // Elabora a string de solicitação de pesquisa do Web Service SimFrete ##
   // ######################################################################
   cComando := ""

   // #################################################################
   // Pesquisa Empresa, usuário e senha para consulta do Web Service ##
   // #################################################################
   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cEmpresaSimFrete := "automatech"
           cLoginSimFrete   := "wscte"
           cSenhaSimfrete   := "12345678"
      Case Substr(cComboBx1,01,02) == "02"
           cEmpresaSimFrete := "ti automacao"
           cLoginSimFrete   := "automatech"
           cSenhaSimfrete   := "12345678"
      Case Substr(cComboBx1,01,02) == "03"
           cEmpresaSimFrete := "atech"
           cLoginSimFrete   := "wscte"
           cSenhaSimfrete   := "12345678"
      Case Substr(cComboBx1,01,02) == "04"
           cEmpresaSimFrete := "atechpel"
           cLoginSimFrete   := "automatech1"
           cSenhaSimfrete   := "12345678"
   EndCase           
           
//   cLoginSimFrete   := "wscte"
//   cSenhaSimfrete   := "12345678"

   // #######################################################
   // Prepara as datas de/até para consulta do Web Service ##
   // #######################################################
   Datade           := Substr(Dtoc(kInicial),07,04) + Substr(Dtoc(kInicial),04,02) + Substr(Dtoc(kInicial),01,02)
   DataAte          := Substr(Dtoc(kFinal)  ,07,04) + Substr(Dtoc(kFinal)  ,04,02) + Substr(Dtoc(kFinal)  ,01,02)
 
   // #################################################
   // Prepara o comando para consultar o Web Service ##
   // #################################################
   cComando := "https://automatech.simfrete.com/consultaconhecimentos7.jsp?" + ;
               "wsemp="           + Alltrim(cEmpresaSimFrete)                + ;
               "&wsusr="          + Alltrim(cLoginSimFrete)                  + ;
               "&wspwd="          + Alltrim(cSenhaSimfrete)                  + ;
               "&alteracaode="    + Alltrim(Datade)                          + ;
               "&alteracaoate="   + Alltrim(DataAte)

   // #######################################################################################
   // Cria nome do arquivo de retorno                                                      ##
   // #######################################################################################
   cRetorno := Alltrim(cCaminhoRetorno) + "CTES_" + Datade + "_" + DataAte + "_" + Alltrim(cFilAnt) + ".TXT" &&  ".HTML"

   // #############################################
   // Fecha o arquivo de retorno para eliminação ##
   // #############################################
   FCLOSE(cRetorno)

   // ###################################################################
   // Elimina o Arquivo para receber nova cotação de frete do SimFrete ##
   // ###################################################################
   FERASE(cRetorno)

   // #############################################
   // Envia a solicitação de cotação ao SimFrete ##
   // #############################################
   WaitRun('AtechHttpget.exe' + ' "' + cComando + '" ' + cRetorno, SW_SHOWNORMAL )

   // ###########################
   // Lê o retorno da consulta ##
   // ###########################
   lExiste     := .F.
   nTentativas := 0

   while nTentativas < cSTIM

      If File(cRetorno)
         lExiste := .T.
         Exit
      Endif

      nTentativas := nTentativas + 1

   Enddo

   // #########################################################
   // Verifica se há arquivo de retorno de coptação de frete ##
   // #########################################################
   If lExiste == .F.

      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo de CTE-s inexistente." + chr(13) + chr(10) + "Tente novamente.")

      // ###############################################################################################
      // Verifica se existe o arquivo de retorno no diretório. Se existir, tenta fechá-lo e excluí-lo ##
      // ###############################################################################################
      If File(cRetorno)

         // ##################
         // Fecha o arquivo ##
         // ##################
         FCLOSE(cRetorno)

         // ########################################################
         // Elimina o Arquivo para receber nova coptação de frete ##
         // ########################################################
         FERASE(cRetorno)

      Endif

      Return(.T.)

   Endif

   ImportaCTES()
   
Return(.T.)

// #################################################
// Função que captura os ctes que foram recebidos ##
// #################################################
Static Function ImportaCTES()

   MsgRun("Aguarde! Importando CTEs recebido ...", "Importação de CTEs",{|| xImportaCTES() })

Return(.T.)

// #################################################
// Função que captura os ctes que foram recebidos ##
// #################################################
Static Function xImportaCTES()

   Local nContar   := 0
   Local aConsulta := {}

   // ########################################
   // Abre o arquivo para capturar os dados ##
   // ########################################
   nHandle := FOPEN(Alltrim(cRetorno), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
      Return .T.
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cLinha    := ""
   lPrimeiro := .T.

   aLista := {}

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(10)
 
          cLinha := cLinha + Substr(xBuffer, nContar, 1)
                
       Else
                                                              
          If Empty(Alltrim(kCNPJ))          
          Else
             If Alltrim(Strtran(U_P_CORTA(cLinha, ",", 01), '"', "")) <> Alltrim(kCNPJ)
                cLinha := ""
                Loop
             Endif
          Endif       

          // #######################################
          // Parametriza a data de emissão do CTe ##
          // #######################################
          kDiaE := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 03), '"', ""), " ", "|") + "|", "|", 3)
          kMesE := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 03), '"', ""), " ", "|") + "|", "|", 2)
          kAnoE := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 03), '"', ""), " ", "|") + "|", "|", 6)

          Do Case
             Case kMesE == "Jan"
                  kEmissao := kDiaE + "/01/" + kAnoE
             Case kMesE == "Feb"
                  kEmissao := kDiaE + "/02/" + kAnoE
             Case kMesE == "Mar"
                  kEmissao := kDiaE + "/03/" + kAnoE
             Case kMesE == "Apr"
                  kEmissao := kDiaE + "/04/" + kAnoE
             Case kMesE == "May"
                  kEmissao := kDiaE + "/05/" + kAnoE
             Case kMesE == "Jun"
                  kEmissao := kDiaE + "/06/" + kAnoE
             Case kMesE == "Jul"
                  kEmissao := kDiaE + "/07/" + kAnoE
             Case kMesE == "Aug"
                  kEmissao := kDiaE + "/08/" + kAnoE
             Case kMesE == "Sep"
                  kEmissao := kDiaE + "/09/" + kAnoE
             Case kMesE == "Oct"
                  kEmissao := kDiaE + "/10/" + kAnoE
             Case kMesE == "Nov"
                  kEmissao := kDiaE + "/11/" + kAnoE
             Case kMesE == "Dec"
                  kEmissao := kDiaE + "/12/" + kAnoE
             Otherwise 
                  kEmissao := "  /  /    "     
          EndCase                  
          
          // ##########################################
          // Parametriza a data de vencimento do CTe ##
          // ##########################################
          kDiaV := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 30), '"', ""), " ", "|") + "|", "|", 3)
          kMesV := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 30), '"', ""), " ", "|") + "|", "|", 2)
          kAnoV := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 30), '"', ""), " ", "|") + "|", "|", 6)

          Do Case
             Case kMesV == "Jan"
                  kVencimento := kDiaV + "/01/" + kAnoV
             Case kMesV == "Feb"
                  kVencimento := kDiaV + "/02/" + kAnoV
             Case kMesV == "Mar"
                  kVencimento := kDiaV + "/03/" + kAnoV
             Case kMesV == "Apr"
                  kVencimento := kDiaV + "/04/" + kAnoV
             Case kMesV == "May"
                  kVencimento := kDiaV + "/05/" + kAnoV
             Case kMesV == "Jun"
                  kVencimento := kDiaV + "/06/" + kAnoV
             Case kMesV == "Jul"
                  kVencimento := kDiaV + "/07/" + kAnoV
             Case kMesV == "Aug"
                  kVencimento := kDiaV + "/08/" + kAnoV
             Case kMesV == "Sep"
                  kVencimento := kDiaV + "/09/" + kAnoV
             Case kMesV == "Oct"
                  kVencimento := kDiaV + "/10/" + kAnoV
             Case kMesV == "Nov"
                  kVencimento := kDiaV + "/11/" + kAnoV
             Case kMesV == "Dec"
                  kVencimento := kDiaV + "/12/" + kAnoV
             Otherwise 
                  kVencimento := "  /  /    "
          EndCase                  

          // ######################################
          // Parametriza a data de Autorizado em ##
          // ######################################
          kDiaA := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 18), '"', ""), " ", "|") + "|", "|", 3)
          kMesA := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 18), '"', ""), " ", "|") + "|", "|", 2)
          kAnoA := U_P_CORTA(StrTran(Strtran(U_P_CORTA(cLinha, ",", 18), '"', ""), " ", "|") + "|", "|", 6)

          Do Case
             Case kMesA == "Jan"
                  kAutorizado := kDiaA + "/01/" + kAnoA
             Case kMesA == "Feb"
                  kAutorizado := kDiaA + "/02/" + kAnoA
             Case kMesA == "Mar"
                  kAutorizado := kDiaA + "/03/" + kAnoA
             Case kMesA == "Apr"
                  kAutorizado := kDiaA + "/04/" + kAnoA
             Case kMesA == "May"
                  kAutorizado := kDiaA + "/05/" + kAnoA
             Case kMesA == "Jun"
                  kAutorizado := kDiaA + "/06/" + kAnoA
             Case kMesA == "Jul"
                  kAutorizado := kDiaA + "/07/" + kAnoA
             Case kMesA == "Aug"
                  kAutorizado := kDiaA + "/08/" + kAnoA
             Case kMesA == "Sep"
                  kAutorizado := kDiaA + "/09/" + kAnoA
             Case kMesA == "Oct"
                  kAutorizado := kDiaA + "/10/" + kAnoA
             Case kMesA == "Nov"
                  kAutorizado := kDiaA + "/11/" + kAnoA
             Case kMesA == "Dec"
                  kAutorizado := kDiaA + "/12/" + kAnoA
             Otherwise 
                  kAutorizado := "  /  /    "
          EndCase                  

          // #################################################
          // Prepara o CNPJ da Transportadora para gravação ##
          // #################################################
          kDocuTran := Strtran(U_P_CORTA(cLinha, ",", 01), '"', "")
          kCNPJTran := Substr(kDocuTran,01,02) + "." + ;
                       Substr(kDocuTran,03,03) + "." + ;
                       Substr(kDocuTran,06,03) + "/" + ;
                       Substr(kDocuTran,09,04) + "-" + ;                          
                       Substr(kDocuTran,13,02)
                          
          // ############################################
          // Prepara o CNPJ do Remetente para gravação ##
          // ############################################
          kDocuReme := Strtran(U_P_CORTA(cLinha, ",", 02), '"', "")
          kCNPJReme := Substr(kDocuReme,01,02) + "." + ;
                       Substr(kDocuReme,03,03) + "." + ;
                       Substr(kDocuReme,06,03) + "/" + ;
                       Substr(kDocuReme,09,04) + "-" + ;                          
                       Substr(kDocuReme,13,02)

          // #####################################
          // Prepara o CNPJ do Pagador do frete ##
          // #####################################
          kDocuPaga  := Strtran(U_P_CORTA(cLinha, ",", 20), '"', "")
          kCNPJPaga  := Substr(kDocuPaga,01,02) + "." + ;
                        Substr(kDocuPaga,03,03) + "." + ;
                        Substr(kDocuPaga,06,03) + "/" + ;
                        Substr(kDocuPaga,09,04) + "-" + ;                          
                        Substr(kDocuPaga,13,02)

          // ####################################
          // Prepara o Tipo de Frete (CIF/FOB) ##
          // ####################################
          kTipoPaga := IIF(Strtran(U_P_CORTA(cLinha, ",", 08), '"', "") == "C", "C - CIF", "F - FOB")

          // #################################
          // Prepara a legenda para display ##
          // #################################
          Do Case
             Case U_P_OCCURS(Upper(Alltrim(Strtran(U_P_CORTA(cLinha, ",", 13), '"', ""))), "LIBERADO", 1) <> 0
                  kLegenda := "2"
                  kNomeLeg := "LIBERADO PGTº"
             Case U_P_OCCURS(Upper(Alltrim(Strtran(U_P_CORTA(cLinha, ",", 13), '"', ""))), "CANCELADO", 1) <> 0
                  kLegenda := "8"
                  kNomeLeg := "CANCELADO"
             Case U_P_OCCURS(Upper(Alltrim(Strtran(U_P_CORTA(cLinha, ",", 13), '"', ""))), "PROCESSADO", 1) <> 0
                  kLegenda := "2"
                  kNomeLeg := "LIBERADO PGTº"
             Case Int(Val(Strtran(U_P_CORTA(cLinha, ",", 06), '"', ""))) == 0
                  kLegenda := "3"
                  kNomeLeg := "LIBERADO PGTº - SEM VALOR AUTORIZADO"
             Otherwise
                  kLegenda := "0"                               
                  kNomeLeg := "INDEFINIDO"                  
          EndCase        

          // #############################################
          // Carrega o grid com o resultado da pesquisa ##
          // #############################################                  
          aAdd( aLista, {.F.                                         ,; // 01
                         kLegenda                                    ,; // 02
                         kCNPJTran                                   ,; // 03
                         kCNPJReme                                   ,; // 04
                         kEmissao                                    ,; // 05
                         Strtran(U_P_CORTA(cLinha, ",", 04), '"', ""),; // 06
                         Strtran(U_P_CORTA(cLinha, ",", 05), '"', ""),; // 07
                         Strtran(U_P_CORTA(cLinha, ",", 06), '"', ""),; // 08
                         Strtran(U_P_CORTA(cLinha, ",", 07), '"', ""),; // 09
                         kTipoPaga                                   ,; // 10
                         Strtran(U_P_CORTA(cLinha, ",", 09), '"', ""),; // 11
                         Strtran(U_P_CORTA(cLinha, ",", 10), '"', ""),; // 12
                         Strtran(U_P_CORTA(cLinha, ",", 11), '"', ""),; // 13
                         Strtran(U_P_CORTA(cLinha, ",", 12), '"', ""),; // 14
                         kNomeLeg                                    ,; // 15
                         Strtran(U_P_CORTA(cLinha, ",", 14), '"', ""),; // 16
                         Strtran(U_P_CORTA(cLinha, ",", 15), '"', ""),; // 17
                         Strtran(U_P_CORTA(cLinha, ",", 16), '"', ""),; // 18
                         Strtran(U_P_CORTA(cLinha, ",", 17), '"', ""),; // 19
                         kAutorizado                                 ,; // 20
                         Strtran(U_P_CORTA(cLinha, ",", 19), '"', ""),; // 21
                         kCNPJPaga                                   ,; // 22
                         Strtran(U_P_CORTA(cLinha, ",", 21), '"', ""),; // 23
                         Strtran(U_P_CORTA(cLinha, ",", 22), '"', ""),; // 24
                         Strtran(U_P_CORTA(cLinha, ",", 23), '"', ""),; // 25
                         Strtran(U_P_CORTA(cLinha, ",", 24), '"', ""),; // 26
                         Strtran(U_P_CORTA(cLinha, ",", 25), '"', ""),; // 27
                         Strtran(U_P_CORTA(cLinha, ",", 26), '"', ""),; // 28
                         Strtran(U_P_CORTA(cLinha, ",", 27), '"', ""),; // 29
                         Strtran(U_P_CORTA(cLinha, ",", 28), '"', ""),; // 30
                         Strtran(U_P_CORTA(cLinha, ",", 29), '"', ""),; // 31                                                      
                         kVencimento                                 }) // 32
         
          cLinha  := ""
            
       Endif


   Next nContar    
   
   // ######################################################################
   // Posição dos campos retornados                                       ##
   // ------------------------------------------------------------------- ##
   // 01 - Marcado (S/N)                                                  ##
   // 02 - Legenda                                                        ##
   // 03 - CNPJ Transportadora                                            ##
   // 04 - Nome da Transportadora                                         ##  
   // 05 - CNPJ do Remetente                                              ##
   // 06 - Nome do Cliente                                                ##
   // 07 - Emissão do CT-e                                                ##
   // 08 - Valor autorizado                                               ##
   // 09 - Cidade/UF de origem                                            ##
   // 10 - Cidade/UF de destino                                           ##
   // 11 - CFOP                                                           ##
   // 12 - Pago A Pagar (CIF/FOB)                                         ##
   // 13 - Base do ICMS                                                   ##
   // 14 - Percentual do ICMS                                             ##
   // 15 - Valor do ICMS                                                  ##
   // 16 - Código fiscal ICMS                                             ##
   // 17 - Situação do CT-e                                               ##
   // 18 - Chave do CT-e                                                  ##
   // 19 - Número do CT-e                                                 ##
   // 20 - Número da Fatura                                               ##
   // 21 - Autorizado por                                                 ##
   // 22 - Autorizado em                                                  ##
   // 23 - Chave NF-e                                                     ##
   // 24 - CNPJ pagador do frete                                          ##
   // 25 - Diferença entre valor autorizado e valor cobrado no CT-e       ##
   // 26 - Diferença entre o valor autorizado e o valor cobrado na fatura ## 
   // 27 - Valor na fatura                                                ##
   // 28 - Indicador de empresa optante pelo Simples Nacional             ##
   // 29 - Tipo da operação                                               ##
   // 30 - Base de cálculo do ISSQN                                       ##
   // 31 - Percentual ISSQN                                               ##
   // 32 - Valor do ISSQN                                                 ##
   // 33 - Código GISS                                                    ##
   // 34 - Vencimento do CT-e                                             ##
   // ######################################################################

   // ################################################
   // Atualiza a tabela ZPN com os CTEs pesquisados ##
   // ################################################
   For nContar = 1 to Len(aLista)

       kVerifica := Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "")

       // ###################################################
       // Considera somente CTE's para documentos de saída ##
       // ###################################################
       If kVerifica$("03385913000161#03385913000242#03385913000404#03385913000595#03385913000676#03385913000757#12757071000112#07166377000164#27379584000104")
       Else
          Loop
       Endif   

       // #######################################################
       // Somente importará registros da Empresa/Filial Logada ##
       // #######################################################
       Do Case
          Case cEmpAnt == "01" .And. cFilAnt == "01"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000161'
                  kEmpresa := "01"
                  kFilial  := "01"
               Else
                  Loop
               Endif
                                       
          Case cEmpAnt == "01" .And. cFilAnt == "02"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000242'
                  kEmpresa := "01"
                  kFilial  := "02"
               Else
                  Loop
               Endif
                     
          Case cEmpAnt == "01" .And. cFilAnt == "03"
               
               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000404'
                  kEmpresa := "01"
                  kFilial  := "03"
               Else
                  Loop
               Endif      

          Case cEmpAnt == "01" .And. cFilAnt == "04"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000595'
                  kEmpresa := "01"
                  kFilial  := "04"
               Else
                  Loop
               Endif

          Case cEmpAnt == "01" .And. cFilAnt == "05"
               
               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000676'
                  kEmpresa := "01"
                  kFilial  := "05"
               Else
                  kEmpresa := "01"
                  kFilial  := "05"
               Endif
                  
          Case cEmpAnt == "01" .And. cFilAnt == "06"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000757'
                  kEmpresa := "01"
                  kFilial  := "06"
               Else
                  Loop
               Endif
                     
          Case cEmpAnt == "02" .And. cFilAnt == "01"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '12757071000112'
                  kEmpresa := "02"
                  kFilial  := "01"
               Else
                  Loop
               Endif
                     
          Case cEmpAnt == "03" .And. cFilAnt == "01"

               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '07166377000164'
                  kEmpresa := "03"   
                  kFilial  := "01"
               Else
                  Loop
               Endif
                     
          Case cEmpAnt == "04" .And. cFilAnt == "01"
               
               If Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '27379584000104'
                  kEmpresa := "04"                 
                  kFilial  := "01"
               Else
                  Loop
               Endif
                     
       EndCase


/*
       // ############################################
       // Prepara o código da Empresa para gravação ##
       // ############################################
       Do Case
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000161'
               kEmpresa := "01"
               kFilial  := "01"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000242'
               kEmpresa := "01"
               kFilial  := "02"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000404'
               kEmpresa := "01"
               kFilial  := "03"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000595'
               kEmpresa := "01"
               kFilial  := "04"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000676'
               kEmpresa := "01"
               kFilial  := "05"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '03385913000757'
               kEmpresa := "01"
               kFilial  := "06"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '12757071000112'
               kEmpresa := "02"
               kFilial  := "01"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '07166377000164'
               kEmpresa := "03"   
               kFilial  := "01"
          Case Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "") == '27379584000104'
               kEmpresa := "04"                 
               kFilial  := "01"
       EndCase

*/


       // #######################################
       // Inclui/Altera registro na tabela ZPN ##
       // #######################################
       DbSelectArea("ZPN")
       DbSetOrder(1)
    
       If DbSeek(kFilial + aLista[nContar,16])
          RecLock("ZPN",.F.) // Altera
       Else
          RecLock("ZPN",.T.) // Inclui
       Endif   

       ZPN->ZPN_FILIAL := kFilial
       ZPN->ZPN_EMPR   := kEmpresa
       ZPN->ZPN_DIMP   := Date()
       ZPN->ZPN_HIMP   := Time()
       ZPN->ZPN_UIMP   := cUserName
       ZPN->ZPN_CGCT   := Strtran(Strtran(Strtran(aLista[nContar,03], ".", ""), "/", ""), "-", "")
       ZPN->ZPN_CGCR   := Strtran(Strtran(Strtran(aLista[nContar,04], ".", ""), "/", ""), "-", "")
       ZPN->ZPN_EMIS   := Ctod(aLista[nContar,05])
       ZPN->ZPN_VALO   := Val(aLista[nContar,06])
       ZPN->ZPN_CORI   := aLista[nContar,07]
       ZPN->ZPN_CDES   := aLista[nContar,08]
       ZPN->ZPN_CFOP   := aLista[nContar,09]
       ZPN->ZPN_PAGO   := Substr(aLista[nContar,10],01,01)
       ZPN->ZPN_BICM   := Val(aLista[nContar,11])
       ZPN->ZPN_PICM   := Val(aLista[nContar,12])
       ZPN->ZPN_VICM   := Val(aLista[nContar,13])
       ZPN->ZPN_CFIS   := aLista[nContar,14]
       ZPN->ZPN_SITU   := aLista[nContar,15]
       ZPN->ZPN_CCTE   := aLista[nContar,16]
       ZPN->ZPN_NCTE   := aLista[nContar,17]
       ZPN->ZPN_NFAT   := aLista[nContar,18]
       ZPN->ZPN_APOR   := aLista[nContar,19]
       ZPN->ZPN_ATEM   := Ctod(aLista[nContar,20])
       ZPN->ZPN_CNFE   := aLista[nContar,21]
       ZPN->ZPN_CGCP   := Strtran(Strtran(Strtran(aLista[nContar,22], ".", ""), "/", ""), "-", "")
       ZPN->ZPN_VDFC   := Val(aLista[nContar,23])
       ZPN->ZPN_VDFA   := Val(aLista[nContar,24])
       ZPN->ZPN_VFAT   := Val(aLista[nContar,25])
       ZPN->ZPN_INDI   := aLista[nContar,26]     
       ZPN->ZPN_TIPO   := aLista[nContar,27]     
       ZPN->ZPN_ISQN   := Val(aLista[nContar,28])
       ZPN->ZPN_PISQ   := Val(aLista[nContar,29])                        
       ZPN->ZPN_VISQ   := Val(aLista[nContar,30])
       ZPN->ZPN_GISS   := aLista[nContar,31]
       ZPN->ZPN_VENC   := Ctod(aLista[nContar,32])
       ZPN->ZPN_DELE   := ""
	   MsUnLock() 
       
   Next nContar    

   aLista := {}
   
   // ###########################################
   // Limpa o grid da tala antes da importação ##
   // ###########################################
   aAdd( aLista, { .F., "0", "1", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;          					             					   
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14],;
         	        	       aLista[oList:nAt,15],;
         	        	       aLista[oList:nAt,16],;
         	        	       aLista[oList:nAt,17],;
         	        	       aLista[oList:nAt,18],;
         	        	       aLista[oList:nAt,19],;
         	        	       aLista[oList:nAt,20],;
         	        	       aLista[oList:nAt,21],;
         	        	       aLista[oList:nAt,22],;
         	        	       aLista[oList:nAt,23],;
         	        	       aLista[oList:nAt,24],;         	        	       
         	        	       aLista[oList:nAt,25],;
         	        	       aLista[oList:nAt,26],;
         	        	       aLista[oList:nAt,27],;
         	        	       aLista[oList:nAt,28],;
         	        	       aLista[oList:nAt,29],;
         	        	       aLista[oList:nAt,30],;
         	        	       aLista[oList:nAt,31],;
         	        	       aLista[oList:nAt,32],;
         	        	       aLista[oList:nAt,33],;
         	        	       aLista[oList:nAt,34],;
         	        	       aLista[oList:nAt,35],;
         	        	       aLista[oList:nAt,36],;
         	        	       aLista[oList:nAt,37],;
         	        	       aLista[oList:nAt,38],;
        	        	       aLista[oList:nAt,39]}}

   MsgAlert("Importação realizada com sucesso!")

   oDlgCON:End() 

Return(.T.)

// ##############################################################
// Função que pesquisa dados da tabela ZPN para popular aLista ##
// ##############################################################
Static Function PesquisaLista(kTipo)

   If kTipo == 1
      MsgRun("Aguarde! Pesquisando dados conforme parâmetros ...", "Pesquisando CTEs",{|| xPesquisaLista(kTipo) })
   Else
      MsgRun("Aguarde! Abrindo parâmetros para montagem de fatura ...", "Pesquisando CTEs",{|| xPesquisaLista(kTipo) })      
   Endif

Return(.T.)

// ##############################################################
// Função que pesquisa dados da tabela ZPN para popular aLista ##
// ##############################################################
Static Function xPesquisaLista(kTipo)

   Local cSql         := ""
   
   Private lVoltaPsq  := .F.
   Private cStringPsq := ""
   
   If kTipo == 1

      If cInicial == Ctod("  /  /    ")
         MsgAlert("Data inicial não informada. Verifique!")
         Return(.T.)
      Endif
      
      If cFinal == Ctod("  /  /    ")
         MsgAlert("Data final não informada. Verifique!")
         Return(.T.)
      Endif

      lMontar := .T.
      
   Else

      // ########################################################################
      // Envia para a função que solicita os parãmetros para geração da fatura ##
      // ########################################################################
      lMontar := .T.

      GetDadosFatura()
      
      If Len(aFatura) == 0
         lMontar := .T.
         Return(.T.)
      Else
         lMontar := .F.
      Endif   

      // #################################
      // Captura os dados para pesquisa ##
      // #################################
      cTransporte := aFatura[01,01]
      cNomeTran   := aFatura[01,02]
      lRaiz       := aFatura[01,03]
      cFatura     := aFatura[01,07]
      nTotalFat   := aFatura[01,12]
      nVenctFat   := aFatura[01,13]
      lPelaFatura := aFatura[01,04]

      oGet8:Refresh()
      oGet9:Refresh()
      oGet10:Refresh()
      oGet11:Refresh()
      oGet12:Refresh()
      oGet13:Refresh()      

      // #################################################################
      // Envia para função que gera a fatura dos registros selecionados ##
      // #################################################################
      GeraFatura()
      
      Return(.T.)

   Endif   

   aLista := {}

   If Select("T_PESQUISA") > 0
      T_PESQUISA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPN_FILIAL,"	+ chr(13)
   cSql += "       ZPN_DIMP  ,"	+ chr(13)
   cSql	+= "       ZPN_HIMP	 ,"	+ chr(13)
   cSql	+= "       ZPN_UIMP	 ,"	+ chr(13)
   cSql	+= "       ZPN_CGCT	 ,"	+ chr(13)
   cSql	+= "       ZPN_CGCR	 ,"	+ chr(13)
   cSql	+= "       ZPN_EMIS	 ,"	+ chr(13)
   cSql	+= "       ZPN_VALO	 ,"	+ chr(13)
   cSql	+= "       ZPN_CORI	 ,"	+ chr(13)
   cSql	+= "       ZPN_CDES	 ,"	+ chr(13)
   cSql	+= "       ZPN_CFOP	 ,"	+ chr(13)
   cSql	+= "       ZPN_PAGO	 ,"	+ chr(13)
   cSql	+= "       ZPN_BICM	 ,"	+ chr(13)
   cSql	+= "       ZPN_PICM	 ,"	+ chr(13)
   cSql	+= "       ZPN_VICM	 ,"	+ chr(13)
   cSql	+= "       ZPN_CFIS	 ,"	+ chr(13)
   cSql	+= "       ZPN_SITU	 ,"	+ chr(13)
   cSql	+= "       ZPN_CCTE	 ,"	+ chr(13)
   cSql	+= "       ZPN_NCTE	 ,"	+ chr(13)
   cSql	+= "       ZPN_NFAT	 ,"	+ chr(13)
   cSql	+= "       ZPN_APOR	 ,"	+ chr(13)
   cSql	+= "       ZPN_ATEM	 ,"	+ chr(13)
   cSql	+= "       ZPN_CNFE	 ,"	+ chr(13)
   cSql	+= "       ZPN_CGCP	 ,"	+ chr(13)
   cSql	+= "       ZPN_VDFC	 ,"	+ chr(13)
   cSql	+= "       ZPN_VDFA	 ,"	+ chr(13)
   cSql	+= "       ZPN_VFAT	 ,"	+ chr(13)
   cSql	+= "       ZPN_INDI	 ,"	+ chr(13)
   cSql	+= "       ZPN_TIPO	 ,"	+ chr(13)
   cSql	+= "       ZPN_ISQN	 ,"	+ chr(13)
   cSql	+= "       ZPN_PISQ	 ,"	+ chr(13)
   cSql	+= "       ZPN_VISQ	 ,"	+ chr(13)
   cSql	+= "       ZPN_GISS	 ,"	+ chr(13)
   cSql	+= "       ZPN_VENC	 ,"	+ chr(13)
   cSql += "       ZPN_DELE	 ,"	+ chr(13)
   cSql += "       ZPN_EMPR   "	+ chr(13)
   cSql += "  FROM ZPN" + Substr(cComboBx1,01,02) + "0"	+ chr(13)
   cSql += " WHERE ZPN_DELE  = ''"	+ chr(13)

   Do Case 

      // ##########################
      // Empresa 01 - Automatech ##
      // ##########################
      Case Substr(cComboBx1,01,02) == "01"

           Do Case          
              Case Substr(cComboBx2,01,02) == "01" // Porto Alegre
                 cSql += " AND ZPN_CGCR = '03385913000161'"	+ chr(13)
              Case Substr(cComboBx2,01,02) == "02" // Caxias do Sul
                 cSql += " AND ZPN_CGCR = '03385913000242'" + chr(13)
              Case Substr(cComboBx2,01,02) == "03" // Pelotas
                 cSql += " AND ZPN_CGCR = '03385913000404'"	+ chr(13)
              Case Substr(cComboBx2,01,02) == "04" // Suprimentos
                 cSql += " AND ZPN_CGCR = '03385913000595'"	+ chr(13)
              Case Substr(cComboBx2,01,02) == "05" // São Paulo
                 cSql += " AND ZPN_CGCR = '03385913000676'"	+ chr(13)
              Case Substr(cComboBx2,01,02) == "06" // Espírito Santo
                 cSql += " AND ZPN_CGCR = '03385913000757'"	+ chr(13)
           EndCase       
                 
      // #############################
      // Empresa 02 - TI Automação  ##
      // #############################
      Case Substr(cComboBx1,01,02) == "02"
           cSql += " AND ZPN_CGCR = '12757071000112'"	+ chr(13)
           
      // #####################
      // Empresa 03 - Atech ##
      // #####################
      Case Substr(cComboBx1,01,02) == "03"
           cSql += " AND ZPN_CGCR = '07166377000164'"	+ chr(13)
           
      // ########################
      // Empresa 04 - AtechPel ##
      // ########################
      Case Substr(cComboBx1,01,02) == "04"
           cSql += " AND ZPN_CGCR = '27379584000104'"	+ chr(13)

   EndCase           

   If kTipo == 1

      Do Case

         Case Substr(cComboBx3,01,01) == "1"
              cSql += "   AND ZPN_DIMP >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"	+ chr(13)
              cSql += "   AND ZPN_DIMP <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"	+ chr(13)

         Case Substr(cComboBx3,01,01) == "2"
              cSql += "   AND ZPN_EMIS >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"	+ chr(13)
              cSql += "   AND ZPN_EMIS <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"	+ chr(13)

         Case Substr(cComboBx3,01,01) == "3"
              cSql += "   AND ZPN_ATEM >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"	+ chr(13)
              cSql += "   AND ZPN_ATEM <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"	+ chr(13)
	     
         Case Substr(cComboBx3,01,01) == "4"
              cSql += "   AND ZPN_VENC >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"	+ chr(13)
              cSql += "   AND ZPN_VENC <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"	+ chr(13)

      EndCase

   Endif   

   If Empty(Alltrim(cTransporte))
   Else            
      If lRaiz == .F.
         cSql += " AND ZPN_CGCT = '" + Alltrim(POSICIONE("SA4",1,XFILIAL("SA4") + cTransporte,"A4_CGC")) + "'"	+ chr(13)
      Else   
         kkCNPJ := POSICIONE("SA4",1,XFILIAL("SA4") + cTransporte,"A4_CGC")	+ chr(13)
         cSql += " AND SUBSTRING(ZPN_CGCT,01,08) = '" + Substr(kkCNPJ,01,08) + "'"	+ chr(13)
      Endif   
   Endif      
        
   If kTipo == 1
      If Empty(Alltrim(cFatura))
      Else
         cSql += " AND ZPN_NFAT = '" + Alltrim(cFatura) + "'"	+ chr(13)
      Endif
   Else
      If lPelaFatura == .F.
      Else
         cSql += " AND ZPN_NFAT = '" + Alltrim(cFatura) + "'"	+ chr(13)
      Endif
   Endif   
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )

   T_PESQUISA->( DbGoTop() )
   
   WHILE !T_PESQUISA->( EOF() )
   
      // #################################
      // Prepara a legenda para display ##
      // #################################
      Do Case
         Case U_P_OCCURS(UPPER(T_PESQUISA->ZPN_SITU), "LIBERADO", 1) <> 0
              kLegenda := "2"
              kNomeLeg := "LIBERADO PGTº"
         Case U_P_OCCURS(UPPER(T_PESQUISA->ZPN_SITU), "CANCELADO", 1) <> 0
              kLegenda := "8"            
              kNomeLeg := "CANCELADO"              
         Case U_P_OCCURS(UPPER(T_PESQUISA->ZPN_SITU), "PROCESSADO", 1) <> 0
              kLegenda := "2"
              kNomeLeg := "LIBERADO PGTº"
         Otherwise
              kLegenda := "0"                               
              kNomeLeg := "INDEFINIDO"
      EndCase        

      // #########################
      // Carrega o nº da fatura ##
      // #########################
      kFatura := T_PESQUISA->ZPN_NFAT

      // #########################################################################################
      // Verifica se o documento já foi incluído. Se foi, considera a legenda Azul - Finalizado ##
      // #########################################################################################
      DbSelectArea("SF1")
      DbSetOrder(8)
      If DbSeek(xFilial("SF1") + T_PESQUISA->ZPN_CCTE)
         kLegenda    := "1"
         kNomeLeg    := "LANÇADO PROTHEUS"
         kDocEntrada := SF1->F1_DOC
         kSerEntrada := SF1->F1_SERIE
         kNaoCancela := .T.

         // #####################################################
         // Verifica se o cte já foi baixado no contas a pagar ##
         // #####################################################
         If Select("T_JABAIXADO") > 0
            T_JABAIXADO->( dbCloseArea() )
         EndIf

         cSql := "SELECT SE2.E2_FATURA ,"
	     cSql += "       SE2.E2_FATFOR ,"
	     cSql += "       SE2.E2_FATLOJ ,"
	     cSql += "       SE2.E2_BAIXA   "
         cSql += "  FROM " + RetSqlName("SE2") + " SE2 "
         cSql += " WHERE SE2.E2_FILORIG  = '" + Alltrim(SF1->F1_FILIAL) + "'"
         cSql += "   AND SE2.E2_NUM      = '" + Alltrim(SF1->F1_DOC)    + "'"
         cSql += "   AND SE2.E2_PREFIXO  = '" + Alltrim(SF1->F1_SERIE)  + "'"
         cSql += "   AND SE2.D_E_L_E_T_  = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JABAIXADO", .T., .T. )

         If T_JABAIXADO->( EOF() )
            kNaoCancela := .T.
         Else
//           If Empty(Alltrim(T_JABAIXADO->E2_FATURA))
            If Empty(Alltrim(T_JABAIXADO->E2_BAIXA))
                kLegenda    := "1"
                kNaoCancela := .T. 
            Else
               kLegenda    := "5"   
               kNaoCancela := .F.          
            Endif   
         Endif   

      Else
         kDocEntrada := ""
         kSerEntrada := ""
         kLegenda    := "2"
         kNomeLeg    := "LIBERADO PGTº"
         kDocEntrada := ""
         kSerEntrada := ""
         kNaoCancela := .T.
      Endif   

      // #################################################################################
      // Se for geração de fatura, somente mostra os registros liberados para pagamento ##
      // #################################################################################
      If kTipo == 2
         If kLegenda == "1" .Or. kLegenda == "2"
         Else
            T_PESQUISA->( DbSkip() )
            Loop
         Endif
      Endif

      // ##################################################
      // Seleciona registros conforme status selecionado ##
      // ##################################################
      Do Case
         // ##################################
         // Status Liberados para Pagamento ##
         // ##################################
         Case Substr(cComboBx4,01,01) == "1"
              If kLegenda <> "2"  
                 T_PESQUISA->( DbSkip() )
                 Loop
              Endif
         // ####################
         // Status Cancelados ##
         // ####################
         Case Substr(cComboBx4,01,01) == "2"
              If kLegenda <> "8"
                 T_PESQUISA->( DbSkip() )
                 Loop
              Endif
         // ##############################
         // Status Lançados no Protheus ##
         // ##############################
         Case Substr(cComboBx4,01,01) == "3"
              If kLegenda <> "1"
                 T_PESQUISA->( DbSkip() )
                 Loop
              Endif
      EndCase         

      // ##########################################################
      // Carrega o código da Filial conforme o CNPJ do remetente ##
      // ##########################################################
      Do Case          
         Case T_PESQUISA->ZPN_CGCR == "03385913000161"
              kFilial := "01"
         Case T_PESQUISA->ZPN_CGCR == "03385913000242"
              kFilial := "02"
         Case T_PESQUISA->ZPN_CGCR == "03385913000404"
              kFilial := "03"
         Case T_PESQUISA->ZPN_CGCR == "03385913000595"
              kFilial := "04"
         Case T_PESQUISA->ZPN_CGCR == "03385913000676"
              kFilial := "05"
         Case T_PESQUISA->ZPN_CGCR == "03385913000757"
              kFilial := "06"
         Case T_PESQUISA->ZPN_CGCR == "12757071000112"
              kFilial := "01"
         Case T_PESQUISA->ZPN_CGCR == "07166377000164"
              kFilial := "01"
         Case T_PESQUISA->ZPN_CGCR == "27379584000104"
              kFilial := "01"
         Otherwise
              kFilial := "00"     
      EndCase           

      // ####################################
      // Pesquisa o nome da Transportadora ##
      // ####################################
      kNomeTranspo := "TRANSPORTADORA NÃO LOCALIZADA"

      If lRaiz == .F.
         kNomeTranspo := POSICIONE("SA2",3,XFILIAL("SA2") + T_PESQUISA->ZPN_CGCT, "A2_NOME")      
      Else
      
         If Select("T_TRANSPORTE") > 0
            T_TRANSPORTE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A2_NOME"
         cSql += "  FROM " + RetSqlName("SA2")
         cSql += " WHERE D_E_L_E_T_ = ''"
         cSql += "   AND SUBSTRING(A2_CGC,01,08) = '" + Substr(T_PESQUISA->ZPN_CGCT,01,08) + "'"
      
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTE", .T., .T. )

         If T_TRANSPORTE->( EOF() )
            kNomeTranspo := "TRANSPORTADORA NÃO LOCALIZADA"
            kLegenda     := "7"
         Else
            kNomeTranspo := T_TRANSPORTE->A2_NOME
         Endif
      Endif   

      // ###############################
      // Pesquisa o nome do Remetente ##
      // ###############################
      kNomeCliente := POSICIONE("SA1",3,XFILIAL("SA1") + T_PESQUISA->ZPN_CGCR, "A1_NOME")

      If Empty(Alltrim(kNomeCliente))
         kNomeCliente := "REMETENTE NÃO LOCALIZADO"
      Endif   
         
      // ################################################################################
      // Filtra somente registros de transportadoras não cadastradas como fornecedores ##
      // ################################################################################
      If Substr(cCombobx4,01,01) == "5"

         xTemTranspo := POSICIONE("SA2",3,XFILIAL("SA2") + T_PESQUISA->ZPN_CGCT, "A2_NOME")      

         If !Empty(Alltrim(xTemTranspo))
            T_PESQUISA->( DbSkip() )
            Loop
         Else
           kLegenda := "7"
         Endif
         
      Endif   

      // #############################################################################
      // Se o valor autorizado do cte for = a 0, considera status 3 = Cancelado (X) ##
      // #############################################################################
      If T_PESQUISA->ZPN_VALO == 0 
         If Empty(Alltrim(kDocEntrada)) 
            If Empty(Alltrim(T_PESQUISA->ZPN_NFAT))
               kLegenda := "3"
            Endif
         Endif      
      Endif   

      // ##########################
      // Alimenta o array aLista ##
      // ##########################
      aAdd( aLista, { .F.                    ,;
                      kLegenda               ,;
                      Substr(T_PESQUISA->ZPN_CGCT,01,02) + "." + Substr(T_PESQUISA->ZPN_CGCT,03,03) + "." +	Substr(T_PESQUISA->ZPN_CGCT,06,03) + "/" + Substr(T_PESQUISA->ZPN_CGCT,09,04) + "-" + Substr(T_PESQUISA->ZPN_CGCT,13,02) ,;
                      kNomeTranspo           ,;
                      Substr(T_PESQUISA->ZPN_CGCR,01,02) + "." + Substr(T_PESQUISA->ZPN_CGCR,03,03) + "." +	Substr(T_PESQUISA->ZPN_CGCR,06,03) + "/" + Substr(T_PESQUISA->ZPN_CGCR,09,04) + "-" + Substr(T_PESQUISA->ZPN_CGCR,13,02) ,;
                      kNomeCliente           ,;
                      Substr(T_PESQUISA->ZPN_EMIS,07,02) + "/" + Substr(T_PESQUISA->ZPN_EMIS,05,02) + "/" + Substr(T_PESQUISA->ZPN_EMIS,01,04) ,;
                      T_PESQUISA->ZPN_VALO	 ,;
                      T_PESQUISA->ZPN_CORI	 ,;
                      T_PESQUISA->ZPN_CDES	 ,;
                      T_PESQUISA->ZPN_CFOP	 ,;
                      IIF(T_PESQUISA->ZPN_PAGO == "C", "C - CIF", "F - FOB") ,;
                      T_PESQUISA->ZPN_BICM	 ,;
                      T_PESQUISA->ZPN_PICM	 ,;
                      T_PESQUISA->ZPN_VICM	 ,;
                      T_PESQUISA->ZPN_CFIS	 ,;
                      kNomeLeg               ,; // T_PESQUISA->ZPN_SITU	 ,;
                      T_PESQUISA->ZPN_CCTE	 ,;
                      T_PESQUISA->ZPN_NCTE	 ,;
                      kFatura                ,; // T_PESQUISA->ZPN_NFAT	 ,;
                      T_PESQUISA->ZPN_APOR	 ,;
                      Substr(T_PESQUISA->ZPN_ATEM,07,02) + "/" + Substr(T_PESQUISA->ZPN_ATEM,05,02) + "/" + Substr(T_PESQUISA->ZPN_ATEM,01,04) ,;
                      T_PESQUISA->ZPN_CNFE	 ,;
                      Substr(T_PESQUISA->ZPN_CGCP,01,02) + "." + Substr(T_PESQUISA->ZPN_CGCP,03,03) + "." +	Substr(T_PESQUISA->ZPN_CGCP,06,03) + "/" + Substr(T_PESQUISA->ZPN_CGCP,09,04) + "-" + Substr(T_PESQUISA->ZPN_CGCP,13,02) ,;
                      T_PESQUISA->ZPN_VDFC	 ,;
                      T_PESQUISA->ZPN_VDFA	 ,;
                      T_PESQUISA->ZPN_VFAT	 ,;
                      T_PESQUISA->ZPN_INDI	 ,;
                      T_PESQUISA->ZPN_TIPO	 ,;
                      T_PESQUISA->ZPN_ISQN	 ,;
                      T_PESQUISA->ZPN_PISQ	 ,;
                      T_PESQUISA->ZPN_VISQ	 ,;
                      T_PESQUISA->ZPN_GISS	 ,;
                      Substr(T_PESQUISA->ZPN_VENC,07,02) + "/" + Substr(T_PESQUISA->ZPN_VENC,05,02) + "/" + Substr(T_PESQUISA->ZPN_VENC,01,04) ,;
                      kDocEntrada            ,;
                      kSerEntrada            ,;
                      T_PESQUISA->ZPN_EMPR   ,;
                      T_PESQUISA->ZPN_FILIAL ,;
                      Strzero(INT(VAL(Substr(T_PESQUISA->ZPN_CCTE,26,09))),9)})

      T_PESQUISA->( DbSkip() )
                          
   ENDDO
   
   If Len(aLista) == 0
      lMontar := .F.
      aAdd( aLista, { .F., "0", "1", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
      MsgAlert("Não existem dados a serem visualizados para estes parâmetros.")
   Endif

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;          					             					   
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14],;
         	        	       aLista[oList:nAt,15],;
         	        	       aLista[oList:nAt,16],;
         	        	       aLista[oList:nAt,17],;
         	        	       aLista[oList:nAt,18],;
         	        	       aLista[oList:nAt,19],;
         	        	       aLista[oList:nAt,20],;
         	        	       aLista[oList:nAt,21],;
         	        	       aLista[oList:nAt,22],;
         	        	       aLista[oList:nAt,23],;
         	        	       aLista[oList:nAt,24],;         	        	       
         	        	       aLista[oList:nAt,25],;
         	        	       aLista[oList:nAt,26],;
         	        	       aLista[oList:nAt,27],;
         	        	       aLista[oList:nAt,28],;
         	        	       aLista[oList:nAt,29],;
         	        	       aLista[oList:nAt,30],;
         	        	       aLista[oList:nAt,31],;
         	        	       aLista[oList:nAt,32],;
         	        	       aLista[oList:nAt,33],;
         	        	       aLista[oList:nAt,34],;
         	        	       aLista[oList:nAt,35],;
         	        	       aLista[oList:nAt,36],;
         	        	       aLista[oList:nAt,37],;
         	        	       aLista[oList:nAt,38],;
        	        	       aLista[oList:nAt,39]}}

   // #############################
   // Atualiza os totais da tela ##
   // #############################
   If Empty(Alltrim(aLista[01,04]))
   Else
      TotalizaTela()
   Endif

Return(.T.)

// #####################################
// Função que totaliza a tela do grid ##
// #####################################
Static Function TotalizaTela()

   Local nContar := 0

   nTotalPsq  := 0
   nTotalSel  := 0
   nDiferenca := 0
   nTotalFat  := 0

   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()      
   oGet13:Refresh()      

   For nContar = 1 to Len(aLista)

       If aLista[nContar,08] == 0
          nTotalPsq := nTotalPsq + (aLista[nContar,25] * -1)       
       Else   
          nTotalPsq := nTotalPsq + aLista[nContar,08]
       Endif

       If aLista[nContar,01] == .T.
          If aLista[nContar,08] == 0
             nTotalSel := nTotalSel + (aLista[nContar,25] * -1)
             nTotalFat := nTotalFat + (aLista[nContar,25] * -1)
          Else   
             nTotalSel := nTotalSel + aLista[nContar,08]
             nTotalFat := nTotalFat + aLista[nContar,08]
          Endif   
       Endif
       
   Next nContar       

   nDiferenca := nTotalPsq - nTotalSel

   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()      
   oGet13:Refresh()         
 
Return(.T.)   

// #################################################################
// Função que gera os documentos de entrada dos CTE's consultados ##
// #################################################################
Static Function GeraDocEnt()

   Private lProcessaDoc := .F.
   
   lProcessaDoc := .F.
   ConfirmaDocEntrada()

   If lProcessaDoc == .F.
      Return(.T.)
   Endif   

   MsgRun("Aguarde! Gerando Documentos de Entrada dos CTEs ...", "Gerando Documentos de Entrada",{|| xGeraDocEnt() })

Return(.T.)

// #################################################################
// Função que gera os documentos de entrada dos CTE's consultados ##
// #################################################################
Static Function xGeraDocEnt()

   Local nContar    := 0
   Local lMarcados  := .F.
   Local lLiberados := .F.
   Local _nErro     := 0
   Local lResult

   Private aCabec      := {}
   Private aItens      := {}
   Private lMsErroAuto := .F.  
   Private lMsHelpAuto := .F.

   PRIVATE aRotina := {{"Pesquisar"   , "AxPesqui"   , 0, 1},;
              		   {"Visualizar"  , "A103NFiscal", 0, 2},; 
		               {"Incluir"     , "A103NFiscal", 0, 3},; 
   		               { "Classificar", "A103NFiscal", 0, 4},; 
		               {"Retornar"    , "A103Devol"  , 0, 3},; 
		               {"Excluir"     , "A103NFiscal", 3, 5},; 
		               {"Imprimir"    , "A103Impri"  , 0, 4},; 
		               {"Legenda"     , "A103Legenda", 0, 2} } 

   // ################################################################# 
   // Verifica se houve pelo menos um registro amrcado para inclusão ##
   // #################################################################
   lMarcados := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar
       
   If lMarcados == .F.
      MsgAlert("Atenção ! Nenhum registro foi marcado para inclusão. Verifique!")
      Return(.T.)
   Endif    

   // ######################################################################### 
   // Verifica se os registro marcados são registros liberados para inclusão ##
   // #########################################################################
   lLiberados := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,02] == "2" .Or. aLista[nContar,02] == "3"
          lLiberados := .T.
          Exit
       Endif
   Next nContar

   If lLiberados == .F.
      MsgAlert("Atenção ! Registro marcados não estão disponíveis para inclusão. Verifique!")
      Return(.T.)
   Endif    

   // ############################################################################ 
   // Verifica se existem registros com cnpj de transportadoras não cadastradas ##
   // ############################################################################
   lLiberados := .F.
   For nContar = 1 to Len(aLista) 
       If aLista[nContar,01] == .T.
          If aLista[nContar,02] == "7"
             lLiberados := .T.
             Exit
          Endif
       Endif   
   Next nContar

   If lLiberados == .T.
      MsgAlert("Atenção ! Existem registro marcados com transportadoras não cadastradas. Verifique!")
      Return(.T.)
   Endif    

   // ##################################################################################################################
   // Inclusão dos CTE's na tabela SF1 - Cabeçalho Notas Fiscais de entrada e SD1 - Ítens de Notas Fiscais de Entrada ##
   // ##################################################################################################################
   For nContar = 1 to Len(aLista)
   
       // ############################################
       // Se registro não foi selecionado, despreza ##
       // ############################################
       If aLista[nContar,01] == .F.
          Loop
       Endif           
       
       // ###################################################
       // Somente irá incluir registro com legenda = Verde ##
       // ###################################################
       If aLista[nContar,02] == "2" .Or. aLista[nContar,02] == "3"
       Else
          Loop
       Endif           

//       // ####################################
//       // Se valor autorizado = 0, despreza ##
//       // ####################################
//       If aLista[nContar,08] == 0  
//          Loop
//       Endif           

       // ###################################################
       // Verifica se o registro pertence a Empresa logada ##
       // ###################################################
       If aLista[nContar,37] == Substr(cComboBx1,01,02)
       Else
          Loop
       Endif

       // ###########################################################
       // Pesquisa os parâmetros para inclusão de produtos de CTEs ##
       // ###########################################################
       If Select("T_PARAMETROS") > 0
          T_PARAMETROS->( dbCloseArea() )
       EndIf
   
       cSql := ""
       cSql := "SELECT ZZ4_PCTE, "
       cSql += "       ZZ4_PCT1, "
       cSql += "       ZZ4_DCTE, "
       cSql += "       ZZ4_SCTE, "
       cSql += "       ZZ4_CCTE, "
       cSql += "       ZZ4_DXML, "
       cSql += "       ZZ4_NATC, "   
       cSql += "       ZZ4_CCUS  "
       cSql += "  FROM " + RetSqlName("ZZ4")

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

       // ######################################
       // Prepara oas variáveis para gravação ##
       // ######################################
       kDocumento  := Strzero(INT(VAL(Substr(aLista[nContar,18],26,09))),9)
       kSerie      := Alltrim(STR(INT(VAL(Substr(aLista[nContar,18],23,03)))))
       kEmissao    := Ctod(aLista[nContar,07])
       kDataBase   := dDataBase   
       kChave      := aLista[nContar,18]  
       kMoeda      := 1
       kCondicao   := T_PARAMETROS->ZZ4_DCTE

       // ##########################################################
       // Carrega o código da Filial conforme o CNPJ do remetente ##
       // ##########################################################
       Do Case          
          Case aLista[nContar,05] == "03.385.913/0001-61"
               kFilial := "01"
          Case aLista[nContar,05] == "03.385.913/0002-42"
               kFilial := "02"
          Case aLista[nContar,05] == "03.385.913/0004-04"
               kFilial := "03"
          Case aLista[nContar,05] == "03.385.913/0005-95"
               kFilial := "04"
          Case aLista[nContar,05] == "03.385.913/0006-76"
               kFilial := "05"
          Case aLista[nContar,05] == "03.385.913/0007-57"
               kFilial := "06"
          Case aLista[nContar,05] == "12.757.071/0001-12"
               kFilial := "01"
          Case aLista[nContar,05] == "07.166.377/0001-64"
               kFilial := "01"
          Case aLista[nContar,05] == "27.379.584/0001-04"
               kFilial := "01"
       EndCase           

       // ######################################
       // Pesquisa o código da transportadora ##
       // ######################################   
       _CNPJ := Strtran(Strtran(Strtran(aLista[nContar,03], ".", ""), "-", ""), "/", "")
       
       kFornecedor := POSICIONE("SA2",3,XFILIAL("SA2") + _CNPJ,"A2_COD" )
       kLoja       := POSICIONE("SA2",3,XFILIAL("SA2") + _CNPJ,"A2_LOJA")

       If Empty(Alltrim(kFornecedor))
          Loop          
       Endif

       // ####################################
       // Pesquisa o estado do cliente (UF) ##
       // ####################################
       If Select("T_ESTADO") > 0
          T_ESTADO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT SA1.A1_EST"
       cSql += "  FROM " + RetSqlName("SA1") + " SA1 "
       cSql += "   WHERE SA1.A1_CGC = '" + Strtran(Strtran(Strtran(aLista[nContar,05], ".", ""), "-", ""), "/", "") + "'"
       cSql += "     AND SA1.D_E_L_E_T_  = ''           "

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTADO", .T., .T. )

       If T_ESTADO->( EOF() )
          MsgAlert("Estado do cliente não localizado.")
          Loop
       Else
          kEstado := T_ESTADO->A1_EST
       Endif
          
       // #################################################################################
       // Limpa os array para receber novos valores para entrada do documento de entrada ##
       // #################################################################################
       aCabec := {}
       aLinha := {}
       aItens := {}

       // #########################
       // Carrega o array aCabec ##
       // #########################
 	   aAdd( aCabec, {"F1_TIPO"   , "N"        , Nil, Nil } )
 	   aAdd( aCabec, {"F1_FORMUL" , "N"        , Nil, Nil } )
 	   aAdd( aCabec, {"F1_FILIAL" , kFilial    , Nil, Nil } )
	   aAdd( aCabec, {"F1_DOC"    , kDocumento , Nil, Nil } )
	   aAdd( aCabec, {"F1_SERIE"  , kSerie     , Nil, Nil } )
	   aAdd( aCabec, {"F1_ESPECIE", "CTE"      , Nil, Nil } )
	   aAdd( aCabec, {"F1_EMISSAO", kEmissao   , Nil, Nil } )
	   aAdd( aCabec, {"F1_DTDIGIT", kDataBase  , Nil, Nil } )
	   aAdd( aCabec, {"F1_FORNECE", kFornecedor, Nil, Nil } )
	   aAdd( aCabec, {"F1_LOJA"   , kLoja      , Nil, Nil } )
       aAdd( aCabec, {"F1_CHVNFE" , kChave     , Nil, Nil } )
 	   aAdd( aCabec, {"F1_TPCTE"  , "N"        , Nil, Nil } )
	   aAdd( aCabec, {"F1_EST"    , kEstado    , Nil, Nil } )
	   aAdd( aCabec, {"F1_MOEDA"  , kMoeda     , Nil, Nil } )
	   aAdd( aCabec, {"F1_COND"   , kCondicao  , Nil, Nil } )

       // ##############################
       // Carrega o Array de Produtos ##
       // ##############################
       kEmissao    := Ctod(aLista[nContar,07])
       kDigitacao  := Ctod(aLista[nContar,07])
       kLocal      := Posicione('SB1', 1, xFilial('SB1') + T_PARAMETROS->ZZ4_PCT1, 'B1_LOCPAD')
       kUnidade    := Posicione('SB1', 1, xFilial('SB1') + T_PARAMETROS->ZZ4_PCT1, 'B1_UM')
       kTipoProd   := Posicione('SB1', 1, xFilial('SB1') + T_PARAMETROS->ZZ4_PCT1, 'B1_TIPO')        
       kProduto    := T_PARAMETROS->ZZ4_PCT1
       kQuantidade := 1

       If aLista[nContar,02] == "2"
          kUnitario   := aLista[nContar,08]
          kTotal      := aLista[nContar,08]
       Else
          kUnitario   := (aLista[nContar,25] * -1)
          kTotal      := (aLista[nContar,25] * -1)
       Endif
          
       kTES        := T_PARAMETROS->ZZ4_SCTE
       kCFOP       := Posicione('SF4', 1, xFilial('SF4') + T_PARAMETROS->ZZ4_SCTE, 'F4_CF')        

       aLinha := {} 
		     
	   aAdd( aLinha, { "D1_FILIAL" , kFilial    , Nil, Nil } )
	   aAdd( aLinha, { "D1_ITEM"   , "0001"     , Nil, Nil } )
	   aAdd( aLinha, { "D1_COD"    , kProduto   , Nil, Nil } )
	   aAdd( aLinha, { "D1_UN"     , kUnidade   , Nil, Nil } )
	   aAdd( aLinha, { "D1_TP"     , kTipoProd  , Nil, Nil } )		
	   aAdd( aLinha, { "D1_QUANT"  , kQuantidade, Nil, Nil } )
   	   aAdd( aLinha, { "D1_VUNIT"  , kUnitario  , Nil, Nil } )
	   aAdd( aLinha, { "D1_TOTAL"  , kTotal     , Nil, Nil } )
       aAdd( aLinha, { "D1_TES"    , kTES       , Nil, Nil } )
       aAdd( aLinha, { "D1_CF"     , kCFOP      , Nil, Nil } )
       aAdd( aLinha, { "D1_EMISSAO", kEmissao   , Nil, Nil } )
 	   aAdd( aLinha, { "D1_DTDIGIT", kDigitacao , Nil, Nil } )
  	   aAdd( aLinha, { "D1_RATEIO" , "1"        , Nil, Nil } )
	   aAdd( aLinha, { "D1_DOC"    , kDocumento , Nil, Nil } )
 	   aAdd( aLinha, { "D1_SERIE"  , kSerie     , Nil, Nil } )
 	   aAdd( aLinha, { "D1_FORNECE", kFornecedor, Nil, Nil } )
	   aAdd( aLinha, { "D1_LOJA"   , kLoja      , Nil, Nil } )												
			
       aAdd( aItens, aLinha )

       // #########################################################
       // Executa rotina padrão do Protheus para inclusão do CTE ##
       // #########################################################
       MsgRun( "Aguarde gerando Nota de Entrada...",, { || MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, 3, .F. ) } )

       If lMsErroAuto
	      MostraErro()
	      Loop

       Endif   
       
   Next nContar

   MsgAlert("CTEs incluídos em Documentos de Entrada com sucesso!")

   // #####################################################
   // Dispara novamente a pesquisa para atualizar a tela ##
   // #####################################################
   PesquisaLista(1)

Return(.T.)

// ###################################################
// Função que gera em excel o resultado da pesquisa ##
// ###################################################
Static Function CarregaExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   aAdd( aCabExcel, { "CNPJ Transportadora"                    , "C",  14, 00 }) 
   aAdd( aCabExcel, { "Descrição Transportadoras"              , "C",  40, 00 }) 
   aAdd( aCabExcel, { "CNPJ Remetente"                         , "C",  14, 00 }) 
   aAdd( aCabExcel, { "Descrição Remetentes NF"                , "C",  40, 00 }) 
   aAdd( aCabExcel, { "Emissão CT-e"                           , "C",  10, 00 }) 
   aAdd( aCabExcel, { "Valor Autorizado"                       , "N",  10, 02 })
   aAdd( aCabExcel, { "Cidade Origem"                          , "C",  30, 00 }) 
   aAdd( aCabExcel, { "Cidade Destino"                         , "C",  30, 00 }) 
   aAdd( aCabExcel, { "CFOP"                                   , "C",  04, 00 }) 
   aAdd( aCabExcel, { "Tp Frete"                               , "C",  01, 00 }) 
   aAdd( aCabExcel, { "Base ICMS"                              , "N",  10, 02 })
   aAdd( aCabExcel, { "% ICMS"                                 , "N",  06, 02 })
   aAdd( aCabExcel, { "Valor ICMS"                             , "N",  10, 02 })
   aAdd( aCabExcel, { "Cod.Fis.ICMS"                           , "C",  05, 00 }) 
   aAdd( aCabExcel, { "Sit. CT-e"                              , "C",  20, 00 }) 
   aAdd( aCabExcel, { "Chave CT-e"                             , "C",  44, 00 }) 
   aAdd( aCabExcel, { "Nº CT-e"                                , "C",  20, 00 }) 
   aAdd( aCabExcel, { "Nº Fatura"                              , "C",  20, 00 }) 
   aAdd( aCabExcel, { "Autorizado por"                         , "C", 100, 00 }) 
   aAdd( aCabExcel, { "Autorizado em"                          , "C",  10, 00 }) 
   aAdd( aCabExcel, { "Chave NF-e"                             , "C", 250, 00 }) 
   aAdd( aCabExcel, { "CNPJ Pagador Frete"                     , "C",  14, 00 }) 
   aAdd( aCabExcel, { "Dif. Valor Aut. X CT-e"                 , "N",  10, 02 })
   aAdd( aCabExcel, { "Dif. Valor Aut. X Valor Cobrado Fatura" , "N",  10, 02 })
   aAdd( aCabExcel, { "Valor da Fatura"                        , "N",  10, 02 })
   aAdd( aCabExcel, { "Simples Nacional"                       , "C",  01, 00 }) 
   aAdd( aCabExcel, { "Tipo Operação"                          , "C",  01, 00 }) 
   aAdd( aCabExcel, { "Base ISSQN"                             , "N",  10, 02 })
   aAdd( aCabExcel, { "% ISSQN"                                , "N",  06, 02 })
   aAdd( aCabExcel, { "Valor do ISSQN"                         , "N",  10, 02 })
   aAdd( aCabExcel, { "Código GISS"                            , "C",  20, 00 }) 
   aAdd( aCabExcel, { "Vencimento do CT-e"                     , "C",  10, 00 }) 
   aAdd( aCabExcel, { "Doc. Entrada"                           , "C",  10, 00 }) 
   aAdd( aCabExcel, { "Série"                                  , "C",  03, 00 })    
   aAdd( aCabExcel, { "Empresa"                                , "C",  02, 00 })    
   aAdd( aCabExcel, { "Filial"                                 , "C",  02, 00 })       
   aAdd( aCabExcel, { "Nº do CTE"                              , "C",  20, 00 })       

   cTitulo := ""
   cTitulo := "Empresa: "        + Alltrim(cComboBx1) + " " + ;
              "Filial: "         + Alltrim(cComboBx2) + " " + ;
              "Data Inicial: "   + Dtoc(cInicial)     + " " + ;
              "Data Final: "     + Dtoc(cFinal)       + " " + ;
              "Tipo Data: "      + Alltrim(cComboBx3) + " " + ;
              "Nº Fatura: "      + Alltrim(cFatura)   + " " + ;
              "Status: "         + Alltrim(cComboBx4) + " " + ;
              "Transportadora: " + Alltrim(cTransporte) + " - " + Alltrim(cNomeTran)                                                                       

   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando Resumo para Excel", {||DlgToExcel({{"GETDADOS",cTitulo, aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, {aLista[nContar,03],;
           			 aLista[nContar,04],;
           			 aLista[nContar,05],;
           			 aLista[nContar,06],;          					             					   
         	         aLista[nContar,07],;
         	         aLista[nContar,08],;
         	         aLista[nContar,09],;
         	         aLista[nContar,10],;
         	         aLista[nContar,11],;
         	         aLista[nContar,12],;
         	         aLista[nContar,13],;
         	         aLista[nContar,14],;
         	         aLista[nContar,15],;
         	         aLista[nContar,16],;
         	         aLista[nContar,17],;
         	         aLista[nContar,18],;
         	         aLista[nContar,19],;
         	         aLista[nContar,20],;
         	         aLista[nContar,21],;
         	         aLista[nContar,22],;
         	         aLista[nContar,23],;
         	         aLista[nContar,24],;         	        	       
         	         aLista[nContar,25],;
         	         aLista[nContar,26],;
         	         aLista[nContar,27],;
         	         aLista[nContar,28],;
         	         aLista[nContar,29],;
         	         aLista[nContar,30],;
         	         aLista[nContar,31],;
        	         aLista[nContar,32],;
         	         aLista[nContar,33],;
        	         aLista[nContar,34],;
         	         aLista[nContar,35],;
        	         aLista[nContar,36],;
         	         aLista[nContar,37],;
        	         aLista[nContar,38],;
        	         aLista[nContar,39],;
                     ""                })

   Next nContar

Return(.T.)

// ########################################
// Função que gera documentos de entrada ##
// ########################################
Static Function ConfirmaDocEntrada()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgPro

   DEFINE MSDIALOG oDlgPro TITLE "Gerar Doc. Entrada CTEs" FROM C(178),C(181) TO C(329),C(535) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgPro

   @ C(028),C(003) GET oMemo1 Var cMemo1 MEMO Size C(170),C(001) PIXEL OF oDlgPro

   @ C(032),C(005) Say "ATENÇÃO!"                                                            Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro
   @ C(043),C(005) Say "Somente serão gerados lançamentos para registros da Empresa logada." Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlgPro

   @ C(058),C(049) Button "Gerar Doc." Size C(037),C(012) PIXEL OF oDlgPro ACTION( lProcessaDoc := .T., oDlgPro:End() )
   @ C(058),C(088) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgPro ACTION( lProcessaDoc := .F., oDlgPro:End() )

   ACTIVATE MSDIALOG oDlgPro CENTERED 

Return(.T.)

// ##################################################
// Função que permite vincular Nº de Fatura ao CTE ##
// ##################################################
Static Function VinculaFatura()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private vTransportadora := aLista[oList:nAt,03] + " - " + aLista[oList:nAt,04]
   Private vCliente        := aLista[oList:nAt,05] + " - " + aLista[oList:nAt,06]
   Private vNumeroCTE	   := aLista[oList:nAt,18]
   Private vFatura 	       := aLista[oList:nAt,20]

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgVin

   DEFINE MSDIALOG oDlgVin TITLE "Vincular Fatura a CTE" FROM C(178),C(181) TO C(457),C(591) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(098),C(022) PIXEL NOBORDER OF oDlgVin

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(198),C(001) PIXEL OF oDlgVin
   @ C(120),C(002) GET oMemo2 Var cMemo2 MEMO Size C(198),C(001) PIXEL OF oDlgVin
   
   @ C(033),C(005) Say "Transportadora" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgVin
   @ C(054),C(005) Say "Cliente"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgVin
   @ C(075),C(005) Say "Nº do CTE"      Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgVin
   @ C(096),C(005) Say "Nº da Fatura"   Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgVin
		   
   @ C(042),C(005) MsGet oGet1 Var vTransportadora Size C(196),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVin When lChumba
   @ C(062),C(005) MsGet oGet2 Var vCliente        Size C(196),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVin When lChumba
   @ C(084),C(005) MsGet oGet3 Var vNumeroCTE      Size C(196),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVin When lChumba
   @ C(105),C(005) MsGet oGet4 Var vFatura         Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgVin

   @ C(124),C(064) Button "Gravar" Size C(037),C(012) PIXEL OF oDlgVin ACTION( GravaFatura() )
   @ C(124),C(102) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgVin ACTION( oDlgVin:End() )
   
	ACTIVATE MSDIALOG oDlgVin CENTERED 

Return(.T.)

// ############################################################
// Função que grava o nº da fatura no registro da tabela ZPN ##
// ############################################################
Static Function GravaFatura()

   Local nContar := 0

   If MsgYesNo("Deseja gravar o nr. deta fatura para todos os registros selecionados?")
      For nContar = 1 to Len(aLista)
          If aLista[ncontar,01] = .T.
             DbSelectArea("ZPN")
             DbSetOrder(1)                                        
             If DbSeek(aLista[nContar,38] + aLista[nContar,18])
                RecLock("ZPN",.F.)
                ZPN->ZPN_NFAT   := vFatura
                MsUnLock() 
                aLista[nContar,20] := vFatura
             Endif
          Endif
      Next nContar
   Else
      DbSelectArea("ZPN")
      DbSetOrder(1)
      If DbSeek(aLista[oList:nAt,38] + vNumeroCTE)
         RecLock("ZPN",.F.)
         ZPN->ZPN_NFAT   := vFatura
         MsUnLock() 
         aLista[oList:nAt,20] := vFatura
      Endif
   Endif   

   oDlgVin:End()

Return(.T.)

// ##########################################################
// Função que gera a fatura conforme parâmetros informados ##
// ##########################################################
Static Function GeraFatura()

   MsgRun("Aguarde! Gerando fatura dos registros selecionados ...", "Geração de Fatura",{|| xGeraFatura() })

Return(.T.)

// ##########################################################
// Função que gera a fatura conforme parâmetros informados ##
// ##########################################################
Static Function xGeraFatura()

   Local nContar      := 0
   Local aFatPag      := {} 
   Local nOpc         := 3 
   Local lTemErro     := .F.
   Local kkValorTotal := 0

   Private lVoltaFat   := .F.

   Private lMsErroAuto := .F.

   //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FIN" 
	   

   If Len(aFatura) == 0
      MsgAlert("Atenção!"                                          + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Processo de montagem da fatura não foi realizado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif   

   If nTotalFat == 0
      MsgAlert("Atenção!"                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Valor total da fatura não foi informado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif   

   If Empty(Alltrim(cFatura))
      MsgAlert("Atenção!"                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Nº da fatura a ser gerada não informada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif   

   If nTotalFat <> nTotalSel
      MsgAlert("Atenção!"                                                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Valor total de CTE selecionados não confere com o valor total da Fatura." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif   

   // ############################################################################
   // Verifica se os dados informado estão coerentes antes da geração da fatura ##
   // ############################################################################
   lTemErro      := .F.
   kkValor_Total := 0

   For nContar = 1 to Len(aLista)
   
       If aLista[ncontar,01] == .F.
          Loop
       Endif
       
       If aLista[nContar,37] <> cEmpAnt
          MsgAlert("Atenção!"                                                                                            + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Fatura não será gerada pois existem registros selecionados que não pertencem a esta Empresa logada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Verifique!")
          lTemErro := .T.
          Exit
       Endif
                 
       If aLista[nContar,38] <> cFilAnt
          MsgAlert("Atenção!"                                                                                           + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Fatura não será gerada pois existem registros selecionados que não pertencem a esta Filial logada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Verifique!")
          lTemErro := .T.
          Exit
       Endif

       If Upper(Alltrim(aLista[nContar,20])) <> Upper(Alltrim(aFatura[01,07]))
          MsgAlert("Atenção!"                                                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Existem registros selecionados que não pertencem ao nº da fatura informada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Verifique!")
          lTemErro := .T.
          Exit
       Endif

       If aLista[nContar,08] == 0
          kkValor_Total := kkValor_Total + (aLista[nContar,25] * -1)
       Else
          kkValor_Total := kkValor_Total + aLista[nContar,08]       
       Endif
       
   Next nContar    

   If lTemErro == .T.
      Return(.T.)
   Endif   

   If kkValor_Total <> aFatura[01,12]
      MsgAlert("Atenção!"                                                                             + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Valor total da Fatura está inconsistente com o valor total das faturas selecionadas." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif      

   // #################################################################################################
   // Realiza a liberação de pagamento para os CTE's selecionados antes de gerar a baixa pela fatura ##
   // #################################################################################################
   For nContar = 1 to Len(aLista)
   
       // ############################################
       // Se registro não foi selecionado, despreza ##
       // ############################################
       If aLista[nContar,01] == .F.
          Loop
       Endif           
       
       // ###################################################
       // Verifica se o registro pertence a Empresa logada ##
       // ###################################################
       If aLista[nContar,37] == Substr(cComboBx1,01,02)
       Else
          Loop
       Endif

       // #########################################################################
       // Pesquisa o título do CTE para incluir a data de liberação de pagamento ##
       // #########################################################################
       DbSelectArea("SF1")
       DbSetOrder(8)
       If DbSeek(xFilial("SF1") + aLista[nContar,18])
          kDocEntrada := SF1->F1_DOC
          kSerEntrada := SF1->F1_SERIE
       Else
          Loop
       Endif      

       // ############################################
       // Atualiza a data de liberação de pagamento ##
       // ############################################
       DbSelectArea("SE2")
       DbSetOrder(1)
       If DbSeek(xFilial("SE2") + kSerEntrada + kDocEntrada + "  " + "NF ")
          RecLock("SE2",.F.)
          SE2->E2_DATALIB := Date()
//         SE2->E2_FATURA := cFatura
   	      MsUnLock() 
   	   Endif
   	   
   Next nContar

   // ###############################################################################
   // Gera o lançamento da fatura aglitinando os cte's selecionado                 ##
   // ---------------------------------------------------------------------------- ##
   // Descricao do Array aFatPag                                                   ##
   // ---------------------------------------------------------------------------- ##
   // [01] - Prefixo                                                               ##
   // [02] - Tipo                                                                  ##
   // [03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)   ##
   // [04] - Natureza                                                              ##
   // [05] - Data de                                                               ##
   // [06] - Data Ate                                                              ##
   // [07] - Fornecedor                                                            ##
   // [08] - Loja                                                                  ##
   // [09] - Fornecedor para geracao                                               ##
   // [10] - Loja do fornecedor para geracao                                       ##
   // [11] - Condicao de pagto                                                     ##
   // [12] - Moeda                                                                 ##
   // [13] - ARRAY com os titulos da fatura                                        ##
   // [13,1] Prefixo                                                               ##
   // [13,2] Numero                                                                ##
   // [13,3] Parcela                                                               ##
   // [13,4] Tipo                                                                  ##
   // [13,5] Título localizado na geracao de fatura (lógico). Iniciar com falso.   ##
   // [14] - Valor de decrescimo                                                   ##
   // [15] - Valor de acrescimo                                                    ##
   // ###############################################################################

   // #############################
   // Inicializa o array aFatPag ##
   // #############################
   aFatPag := {}

   // ##########################
   // Carrega o array aFatPag ##
   // ##########################
   Aadd(aFatPag, aFatura[01,05])           // Prefixo            1
   Aadd(aFatPag, aFatura[01,06])           // Tipo               2
   Aadd(aFatPag, aFatura[01,07])           // Numero da Fatura   3
   Aadd(aFatPag, aFatura[01,08])           // Natureza           4
   Aadd(aFatPag, aFatura[01,10])           // Data de            5
   Aadd(aFatPag, aFatura[01,11])           // Data Ate           6
   Aadd(aFatPag, aFatura[01,14])           // Fornecedor         7
   Aadd(aFatPag, aFatura[01,15])           // Loja               8
   Aadd(aFatPag, aFatura[01,17])           // Fornecedor para geracao  9
   Aadd(aFatPag, aFatura[01,18])           // Loja do fornecedor para geracao  10
   Aadd(aFatPag, aFatura[01,20])           // Condicao de pagto 11
   Aadd(aFatPag, INT(VAL(aFatura[01,09]))) // Moeda            12

   // ################################################################
   // Inclui os CTE's a serem baixados referente a fatura elaborada ##
   // ################################################################
   
   aTit := {}
   
   For nContar = 1 to Len(aLista)
   
       If aLista[nContar,01] == .F.
          Loop
       Endif   

       kDocumento := Strzero(INT(VAL(Substr(aLista[nContar,18],26,09))),9)
       kSerie     := Alltrim(STR(INT(VAL(Substr(aLista[nContar,18],23,03)))))
       kParcela   := ""
       kTipoLanc  := "NF"

       // ###################################################################################################################################
       // ARRAY com os titulos da fatura (Prefixo,Numero,Parcela,Tipo,Título localizado na geracao de fatura (lógico). Iniciar com falso.) ##
       // ###################################################################################################################################
       //Aadd(aFatPag, {{kSerie, kDocumento, "   ", "NF ", .F.}}) 
       
//		Aadd(aTit, {kSerie, kDocumento, "", "NF ", .T.}) 

		Aadd(aTit, {PADR(kSerie    , TAMSX3("E2_PREFIXO")[1]),;
		            PADR(kDocumento, TAMSX3("E2_NUM")[1])    ,;
		            PADR(kParcela  , TAMSX3("E2_PARCELA")[1]),;		            
		            PADR(kTipoLanc , TAMSX3("E2_TIPO")[1])   ,;		            
		            .F.}) 

   Next nContar                                        
   
   Aadd(aFatPag, aTit)                    
   Aadd(aFatPag, 0) // Valor de decrescimo 
   Aadd(aFatPag, 0) // Valor de acrescimo 

   lMsErroAuto := .F. 

   MsExecAuto( { |x,y| FINA290(x,y)},3,aFatPag,)

   IF lMsErroAuto 

      MostraErro() 

   EndIF 
   
   //RESET ENVIRONMENT 
Return(.T.)

// #####################################################
// Função que solicita dados para a geração da fatura ##
// #####################################################
Static Function GetDadosFatura()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private yCodTran	   := cTransporte
   Private yNomeTra    := cNomeTran
   Private yRaiz 	   := .T.
   Private yExata	   := .T.
   Private yPrefixo    := "FAT"
   Private yTipo       := "FT"
   Private yFatura 	   := Space(09)
   Private yNatureza   := "6700110   "
   Private yDataDe	   := cInicial
   Private yDataAte	   := cFinal
   Private yValorFat   := nTotalFat
   Private yVencimento := Ctod("  /  /    ")

   Private yForne1	   := Space(06)
   Private yLoja1 	   := Space(03)
   Private yNome1	   := Space(40)

   Private yForne2     := Space(06)
   Private yLoja2  	   := Space(03)
   Private yNome2 	   := Space(40)

   Private yCondicao   := "174"
   Private yNomeCond   := POSICIONE("SE4",1,XFILIAL("SE4") + "174","E4_DESCRI")

   Private aMoeda      := {"01 - Real", "02 - Dolar"}
   Private cMoeda

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private oGet17
   Private oGet18

   Private oCheckBox1
   Private oCheckBox2

   Private oDlgFat

   aFatura := {}

   // ###################################################################
   // Pesquisa o fornecedor caso a transportadora tenha cido informada ##
   // ###################################################################
   If Empty(Alltrim(cTransporte))
   Else

      kkCNPJT := POSICIONE("SA4",1,XFILIAL("SA4") + cTransporte, "A4_CGC")
  
      If Empty(Alltrim(kkCNPJT))
      Else
         yForne1 := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_COD" )
         yLoja1  := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_LOJA")
         yNome1	 := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_NOME")
         yForne2 := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_COD" )
         yLoja2  := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_LOJA")
         yNome2  := POSICIONE("SA2",3,XFILIAL("SA2") + kkCNPJT, "A2_NOME")
      Endif
   Endif

   DEFINE MSDIALOG oDlgFat TITLE "Faturas a Pagar abaixo informada" FROM C(178),C(181) TO C(642),C(598) PIXEL Style DS_MODALFRAME

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(114),C(023) PIXEL NOBORDER OF oDlgFat

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(202),C(001) PIXEL OF oDlgFat
   @ C(087),C(002) GET oMemo3 Var cMemo3 MEMO Size C(202),C(001) PIXEL OF oDlgFat
   @ C(212),C(002) GET oMemo2 Var cMemo2 MEMO Size C(202),C(001) PIXEL OF oDlgFat

   @ C(033),C(005) Say "DADOS PARA PESQUISA DE CTE's" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(092),C(005) Say "DADOS PARA GERAÇÃO DA FATURA" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(043),C(005) Say "Transportadora"               Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(103),C(005) Say "Prefixo"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(103),C(029) Say "Tp"                           Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(103),C(053) Say "Nº Fatura"                    Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(103),C(104) Say "Natureza"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(103),C(160) Say "Moeda"                        Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(125),C(005) Say "Emissão de"                   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(125),C(053) Say "Emissão Até"                  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(125),C(104) Say "Valor da Fatura"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(125),C(160) Say "Venctº Fatura"                Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(147),C(005) Say "Fornecedor"                   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(169),C(005) Say "Gerar para o Fornecedor"      Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
   @ C(191),C(005) Say "Condição de Pagamento"        Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgFat
                                   
   @ C(052),C(005) MsGet    oGet16     Var   yCodTran    Size C(025),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SA4") VALID( PsqtransFor() )
   @ C(052),C(036) MsGet    oGet17     Var   yNomeTra    Size C(168),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat When lChumba
   @ C(065),C(036) CheckBox oCheckBox1 Var   yRaiz       Prompt "Pesquisar pelo raiz do CNPJ da transportadora"               Size C(122),C(008) PIXEL OF oDlgFat
   @ C(075),C(036) CheckBox oCheckBox2 Var   yExata      Prompt "Pesquisar CTE's com número exato da fatura abaixo informada" Size C(159),C(008) PIXEL OF oDlgFat
   @ C(112),C(005) MsGet    oGet1      Var   yPrefixo    Size C(019),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat
   @ C(112),C(029) MsGet    oGet2      Var   yTipo       Size C(018),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SX5","05")
   @ C(112),C(053) MsGet    oGet3      Var   yFatura     Size C(044),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat
   @ C(112),C(104) MsGet    oGet4      Var   yNatureza   Size C(050),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SED")
   @ C(112),C(160) ComboBox cMoeda     Items aMoeda      Size C(044),C(010)                                         PIXEL OF oDlgFat When lChumba
   @ C(134),C(005) MsGet    oGet5      Var   yDataDe     Size C(043),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat
   @ C(134),C(053) MsGet    oGet6      Var   yDataAte    Size C(044),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat
   @ C(134),C(104) MsGet    oGet7      Var   yValorFat   Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgFat
   @ C(134),C(160) MsGet    oGet18     Var   yVencimento Size C(044),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat
   @ C(156),C(005) MsGet    oGet8      Var   yForne1     Size C(030),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SA2")
   @ C(156),C(041) MsGet    oGet9      Var   yLoja1      Size C(018),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat VALID( yNome1 := POSICIONE("SA2",1,XFILIAL("SA2") + yForne1 + yLoja1, "A2_NOME") )
   @ C(156),C(065) MsGet    oGet10     Var   yNome1      Size C(139),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat When lChumba
   @ C(178),C(005) MsGet    oGet11     Var   yForne2     Size C(030),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SA2")
   @ C(178),C(041) MsGet    oGet12     Var   yLoja2      Size C(018),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat VALID( yNome2 := POSICIONE("SA2",1,XFILIAL("SA2") + yForne2 + yLoja2, "A2_NOME") )
   @ C(178),C(065) MsGet    oGet13     Var   yNome2      Size C(139),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat When lChumba
   @ C(200),C(004) MsGet    oGet14     Var   yCondicao   Size C(030),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat F3("SE4") VALID( yNomeCond := POSICIONE("SE4",1,XFILIAL("SE4") + yCondicao, "E4_DESCRI") )
   @ C(200),C(041) MsGet    oGet15     Var   yNomeCond   Size C(162),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgFat When lChumba

   @ C(216),C(066) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgFat ACTION( CfmGerFat() )
   @ C(216),C(105) Button "Cancelar"  Size C(037),C(012) PIXEL OF oDlgFat ACTION( oDlgFat:End() )

   ACTIVATE MSDIALOG oDlgFat CENTERED 

Return(.T.)

// ##################################################################################
// Função que pesquisa a transportadora e fornecedor pelo código da transportadora ##
// ##################################################################################
Static Function PsqtransFor()

   If Empty(Alltrim(yCodTran))
      Return(.T.)
   Endif
           
   ynometra  := POSICIONE("SA4",1,XFILIAL("SA4") + yCodTran, "A4_NOME"  )
   yyCNPJFor := POSICIONE("SA4",1,XFILIAL("SA4") + yCodTran, "A4_CGC"   )
   yForne1   := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_COD"  )
   yLoja1    := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_LOJA" )   
   yNome1    := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_NOME" )   
   yForne2   := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_COD"  )
   yLoja2    := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_LOJA" )   
   yNome2    := POSICIONE("SA2",3,XFILIAL("SA4") + yyCNPJFor, "A2_NOME" )   

Return(.T.)

// ##############################################################
// Função que confirma dados informados para geração da fatura ##
// ##############################################################
Static Function CfmGerFat()

   If Empty(Alltrim(yCodTran))
      MsgAlert("Transportadora a ser pesquisada não informada. Verifiqeu!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(yPrefixo))
      MsgAlert("Prefixo não informado. Verifiqeu!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(yTipo))
      MsgAlert("Tipo não informado. Verifiqeu!")
      Return(.T.)
   Endif

   If Empty(Alltrim(yFatura))
      MsgAlert("Nº da fatura não informada. Verifiqeu!")
      Return(.T.)
   Endif

   If Empty(Alltrim(yNatureza))
      MsgAlert("Natureza não informada. Verifiqeu!")
      Return(.T.)
   Endif

   If yDataDe == Ctod("  /  /    ")
      MsgAlert("Data De não informada. Verifiqeu!")
      Return(.T.)
   Endif
      
   If yDataAte == Ctod("  /  /    ")
      MsgAlert("Data Até não informada. Verifiqeu!")
      Return(.T.)
   Endif

   If yValorFat == 0
      MsgAlert("Valor da Fatura não informada. Verifiqeu!")
      Return(.T.)
   Endif

   If yVencimento == Ctod("  /  /    ")
      MsgAlert("Vencimento da fatura não informado. Verifiqeu!")
      Return(.T.)
   Endif

   IF Empty(Alltrim(yForne1))
      MsgAlert("Fornecedor não informado. Verifique!")
      Return(.T.)
   Endif      

   IF Empty(Alltrim(yLoja1))
      MsgAlert("Fornecedor não informado. Verifique!")
      Return(.T.)
   Endif      

   IF Empty(Alltrim(yForne2))
      MsgAlert("Fornecedor a ser gerado não informado. Verifique!")
      Return(.T.)
   Endif      

   IF Empty(Alltrim(yLoja2))
      MsgAlert("Fornecedor a ser gerado não informado. Verifique!")
      Return(.T.)
   Endif      

   IF Empty(Alltrim(yCondicao))
      MsgAlert("Condição de Pagamento não informada. Verifique!")
      Return(.T.)
   Endif      

   aFatura := {}
   
   aAdd( aFatura, {yCodTran   ,; // 01
                   yNomeTra   ,; // 02
                   yRaiz      ,; // 03
                   yExata     ,; // 04
                   yPrefixo   ,; // 05
                   yTipo      ,; // 06
                   yFatura    ,; // 07
                   yNatureza  ,; // 08
                   "01"       ,; // 09
                   yDataDe    ,; // 10
                   yDataAte   ,; // 11
                   yValorFat  ,; // 12
                   yVencimento,; // 13
                   yForne1    ,; // 14
                   yLoja1     ,; // 15
                   yNome1     ,; // 16
                   yForne2    ,; // 17
                   yLoja2     ,; // 18
                   yNome2     ,; // 19
                   yCondicao  ,; // 20
                   yNomeCond  }) // 21

   oDlgFat:End() 
   
Return(.T.)   








/*

       Aadd(aFatPag, {{"U ", "410376", " ", "NF ", .F.},; 
                      {"U ", "410887", " ", "NF ", .F.},; 
                      {"U ", "410888", " ", "NF ", .F.},; 
                      {"U ", "410889", " ", "NF ", .F.},; 
                      {"U ", "410890", " ", "NF ", .F.},; 
                      {"U ", "410891", " ", "NF ", .F.},; 
                      {"U ", "410892", " ", "NF ", .F.},; 
                      {"U ", "410893", " ", "NF ", .F.},; 
                      {"U ", "410894", " ", "NF ", .F.},; 
                      {"U ", "410895", " ", "NF ", .F.},; 
                      {"U ", "410896", " ", "NF ", .F.},; 
                      {"U ", "410897", " ", "NF ", .F.},; 
                      {"U ", "410898", " ", "NF ", .F.},; 
                      {"U ", "410899", " ", "NF ", .F.},; 
                      {"U ", "410900", " ", "NF ", .F.},; 
                      {"U ", "410901", " ", "NF ", .F.},; 
                      {"U ", "410902", " ", "NF ", .F.},; 
                      {"U ", "410903", " ", "NF ", .F.},; 
                      {"U ", "410904", " ", "NF ", .F.},; 
                      {"U ", "410905", " ", "NF ", .F.},; 
                      {"U ", "410906", " ", "NF ", .F.},; 
                      {"U ", "410907", " ", "NF ", .F.},; 
                      {"U ", "410908", " ", "NF ", .F.},; 
                      {"U ", "410909", " ", "NF ", .F.},; 
                      {"U ", "410910", " ", "NF ", .F.},; 
                      {"U ", "410911", " ", "NF ", .F.},; 
                      {"U ", "410912", " ", "NF ", .F.},; 
                      {"U ", "410913", " ", "NF ", .F.},; 
                      {"U ", "410914", " ", "NF ", .F.},; 
                      {"U ", "411113", " ", "NF ", .F.},; 
                      {"U ", "411291", " ", "NF ", .F.},; 
                      {"U ", "411292", " ", "NF ", .F.},; 
                      {"U ", "411293", " ", "NF ", .F.},; 
                      {"U ", "411294", " ", "NF ", .F.}}) 

*/






