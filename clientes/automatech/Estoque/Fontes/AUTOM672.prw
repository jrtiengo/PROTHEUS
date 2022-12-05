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

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM672.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 23/01/2018                                                          ##
// Objetivo..: Programa que verifica o campo Ident entre a tabela SD1 e SB6.       ##
//             Veririfca lançamentos que possuem Campo Ident da Sd1 diferente com  ##
//             a tabela SB6.                                                       ##
// ##################################################################################

User Function AUTOM672()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local oMemo1
   
   Private aFiliais	   := {}
   Private aStatus     := {"0 - Selecione", "1 - Consistentes", "2 - Inconsistentes", "3 - Ambos" }

   Private cComboBx1
   Private cComboBx2
   
   Private aDocumento  := {}
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private cNota       := Space(09)
   Private cSerie      := Space(03)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

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

   Private oDlg

   // #########################################################
   // Carrega as datas Iniciais e Finais com o período atual ##
   // #########################################################
   cDtaInicial := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   cDtaFinal   := LastDay(Date())

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   aFiliais := U_AUTOM539(2, cEmpAnt)

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Lançamentos com erro no campo IDENT - Poder de Terceiros" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(126) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(250) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Filial"                           Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(065) Say "Dta Inicial"                      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(107) Say "Dta Final"                        Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(152) Say "Documento"                        Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(195) Say "Série"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(218) Say "Status"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(140) Say "Registros Inconsistentes"         Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(260) Say "Regsitros Consistentes"           Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1 Items aFiliais     Size C(055),C(010)                              PIXEL OF oDlg
   @ C(045),C(066) MsGet    oGet1     Var   cDtaInicial  Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(109) MsGet    oGet2     Var   cDtaFinal    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg  
   @ C(045),C(152) MsGet    oGet3     Var   cNota        Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(195) MsGet    oGet4     Var   cSerie       Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(218) ComboBox cComboBx2 Items aStatus      Size C(088),C(010)                              PIXEL OF oDlg

   @ C(043),C(461) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( DifIdent() )
   @ C(210),C(005) Button "Marca"    Size C(037),C(012) PIXEL OF oDlg ACTION( MDistribui(1) )
   @ C(210),C(042) Button "Desmarca" Size C(037),C(012) PIXEL OF oDlg ACTION( MDistribui(2) )
   @ C(210),C(079) Button "Detalhes" Size C(037),C(012) PIXEL OF oDlg ACTION( MostraDife() )

   @ C(210),C(383) Button "Excel"    Size C(037),C(012) PIXEL OF oDlg ACTION( kSaidaExcel() )
   @ C(210),C(422) Button "Corrigir" Size C(037),C(012) PIXEL OF oDlg ACTION( CorrigeIdent(2) )
   @ C(210),C(461) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 0 } )

   @ 080,005 LISTBOX oList FIELDS HEADER "Mrc"                       ,; // 01
                                         "Lgn"                       ,; // 02
                                         "Filial"                    ,; // 03
                                         "Fornecedor"                ,; // 04
                                         "Loja"                      ,; // 05
                                         "Descrição dos Fornecedores",; // 06
                                         "Data Emissão"              ,; // 07
                                         "Documento"                 ,; // 08
                                         "Série"                     ,; // 09
                                         "TES"                       ,; // 10
                                         "Descrição das TES"         ,; // 11
                                         "Item"                      ,; // 12
                                         "Produto"                   ,; // 13
                                         "Descrição dos Produtos"    ,; // 14
                                         "IDENT (SB6)"               ,; // 15
                                         "IDENT (SD1)"               ,; // 16
                                         "RECNO (SD1)"                ; // 17
                                         PIXEL SIZE 633,185 OF oDlg ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())      

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
         	        	       aLista[oList:nAt,17]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################################
// Função que marca e desmarca as ordens de serviço para distribuição ##
// #####################################################################
Static Function MDistribui(_Botao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)

       If Empty(Alltrim(aLista[nContar,03]))
          Loop
       Endif

       If aLista[nContar,01] == .F.
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.
       Endif

   Next nContar       

   oList:Refresh()
   
Return(.T.)                

// ########################################################################################
// Função que pesquisa os lanlamentos com diferenças no campo IDENT - Poder de Terceiros ##
// ########################################################################################
Static Function DifIdent()

   MsgRun("Aguarde! Pesquisando Registros Divergentes ...", "Poder de Terceiros",{|| xDifIdent() })

Return(.T.)

// ########################################################################################
// Função que pesquisa os lanlamentos com diferenças no campo IDENT - Poder de Terceiros ##
// ########################################################################################
Static Function xDifIdent()

   Local cSql       := ""
   Local nContar    := 0
   Local lExisteReg := .F.
      
   If cDtaInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif   
   
   If cDtaFinal == Ctod("  /  /    ")
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif   

   If Substr(cComboBx2,01,01) == "0"
      MsgAlert("Status de pesquisa não selecionado.")
      Return(.T.)
   Endif   

   aLista     := {}
   aDocumento := {}
   aTransito  := {}

   // #####################
   // Pesquisa registros ##
   // #####################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SB6.B6_FILIAL ,"
   cSql += "       SB6.B6_CLIFOR ,"
   cSql += "       SB6.B6_LOJA   ,"
   cSql += "	   SB6.B6_PRODUTO,"
   cSql += "       SB6.B6_EMISSAO,"
   cSql += "       SB6.B6_TES    ,"
   cSql += "	   SB6.B6_DOC    ,"
   cSql += "	   SB6.B6_SERIE  ,"
   cSql += "	   SB6.B6_IDENT  ,"
   cSql += "	   SB6.R_E_C_N_O_,"
   cSql += "       '   ' AS ITEM  "
   cSql += "  FROM " + RetSqlName("SB6") + " SB6 (Nolock) "
   cSql += " WHERE SB6.D_E_L_E_T_  = ''"
   cSql += "   AND SB6.B6_FILIAL   = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SB6.B6_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
   cSql += "   AND SB6.B6_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"

   If Empty(Alltrim(cNota))
   Else
      cSql += "   AND SB6.B6_DOC = '" + Alltrim(cNota) + "'"
   Endif   
      
   If Empty(Alltrim(cSerie))
   Else
      cSql += "   AND SB6.B6_SERIE = '" + Alltrim(cSerie) + "'"
   Endif

   cSql += " ORDER BY SB6.B6_FILIAL, SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_CLIFOR, SB6.B6_LOJA, SB6.R_E_C_N_O_"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   // #########################
   // Carrega o array aLista ##
   // #########################
   T_CONSULTA->( DbGoTop() )

   WHILE !T_CONSULTA->( EOF() )
   
      kNomeFornecedor := POSICIONE("SA1", 1, XFILIAL("SA1") + T_CONSULTA->B6_CLIFOR + T_CONSULTA->B6_LOJA, "A1_NOME" )
      kNomeTES        := Posicione("SF4", 1, xFilial("SF4") + T_CONSULTA->B6_TES                         , "F4_TEXTO")
      kEmissao        := Substr(T_CONSULTA->B6_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->B6_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->B6_EMISSAO,01,04)
      kNomeProduto    := Posicione("SB1", 1, xFilial("SB1") + T_CONSULTA->B6_PRODUTO                     , "B1_DESC" ) + " " + ;
                         Posicione("SB1", 1, xFilial("SB1") + T_CONSULTA->B6_PRODUTO                     , "B1_DAUX" )
        
      // #########################
      // Carrega o array aLista ##
      // #########################
      aAdd( aLista, { .F.                   ,; // 01
                      "2"                   ,; // 02
                      T_CONSULTA->B6_FILIAL ,; // 03
                      T_CONSULTA->B6_CLIFOR ,; // 04
                      T_CONSULTA->B6_LOJA   ,; // 05
                      kNomeFornecedor       ,; // 06
                      kEmissao              ,; // 07
                      T_CONSULTA->B6_DOC    ,; // 08
                      T_CONSULTA->B6_SERIE  ,; // 09
                      T_CONSULTA->B6_TES    ,; // 10
                      kNomeTES              ,; // 11
                      T_CONSULTA->ITEM      ,; // 12
                      T_CONSULTA->B6_PRODUTO,; // 13
                      kNomeProduto          ,; // 14
                      T_CONSULTA->B6_IDENT  ,; // 15
                      ""                    ,; // 16
                      0                     }) // 17

      T_CONSULTA->( DbSkip() )
      
   ENDDO   

   // ###########################################################################
   // Grava o campo T_CONSULTA->ITEM com a sequencia de cada nota fiscal/série ##
   // ###########################################################################
   kFilial    := aLista[01,03]
   kCliente   := aLista[01,04]
   kLoja      := aLista[01,05]
   kDocumento := aLista[01,08]
   kSerie     := aLista[01,09]
   kItem      := 1   

   For nContar = 1 to Len(aLista)
   
      If aLista[nContar,03] == kFilial    .And. ;
         aLista[nContar,04] == kCliente   .And. ;
         aLista[nContar,05] == kLoja      .And. ;
         aLista[nContar,08] == kDocumento .And. ;
         aLista[nContar,09] == kSerie    
         aLista[nContar,12] := Strzero(kItem,04)
         kItem := kItem + 1
         Loop
      Else
         kFilial    := aLista[nContar,03]
         kCliente   := aLista[nContar,04]
         kLoja      := aLista[nContar,05]
         kDocumento := aLista[nContar,08]
         kSerie     := aLista[nContar,09]
         kItem      := 1   
         aLista[nContar,12] := Strzero(kItem,04)
         kItem := kItem + 1
      Endif

   Next nContar

   // #################################
   // Pesquisa o Ident da Tabela SD1 ##
   // #################################
   For nContar = 1 to Len(aLista)

       If Posicione("SF4", 1, xFilial("SF4") + aLista[nContar,10], "F4_TIPO") == "E"
          dbSelectArea("SD1")
          dbSetOrder(1)
	      If dbSeek( aLista[nContar,03] + aLista[nContar,08] + aLista[nContar,09] + aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,13] + aLista[nContar,12])
             aLista[nContar,16] := SD1->D1_IDENTB6             
             aLista[nContar,17] := RECNO() 
          Else
             If dbSeek( aLista[nContar,03] + aLista[nContar,08] + aLista[nContar,09] + aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,13])
                aLista[nContar,16] := SD1->D1_IDENTB6             
                aLista[nContar,17] := RECNO() 
             Else

                If Select("T_CODIGO") > 0
                   T_CODIGO->( dbCloseArea() )
                EndIf

                cSql := "SELECT D1_IDENTB6,"
                cSql += "       R_E_C_N_O_ "
                cSql += "  FROM " + RetSqlName("SD2")
                cSql += " WHERE D1_FILIAL  = '" + Alltrim(aLista[nContar,03]) + "'"
                cSql += "   AND D1_DOC     = '" + Alltrim(aLista[nContar,08]) + "'"
                cSql += "   AND D1_SERIE   = '" + Alltrim(aLista[nContar,09]) + "'"
                cSql += "   AND D1_COD     = '" + Alltrim(aLista[nContar,13]) + "'"
                cSql += "   AND D1_IDENTB6 = '" + Alltrim(aLista[nContar,15]) + "'"
                cSql += "   AND D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODIGO", .T., .T. )

                If T_CODIGO->( EOF() )
                   Loop
                Else
                   aLista[nContar,16] := T_CODIGO->D1_IDENTB6                                
                   aLista[nContar,17] := T_CODIGO->R_E_C_N_O_ 
                Endif   

             Endif   
          Endif
       Else
          dbSelectArea("SD2")
          dbSetOrder(1)
	      If dbSeek( aLista[nContar,03] + aLista[nContar,08] + aLista[nContar,09] + aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,13] + aLista[nContar,12])
             aLista[nContar,16] := SD2->D2_IDENTB6             
             aLista[nContar,17] := RECNO() 
          Else
             If dbSeek( aLista[nContar,03] + aLista[nContar,08] + aLista[nContar,09] + aLista[nContar,04] + aLista[nContar,05] + aLista[nContar,13])
                aLista[nContar,16] := SD2->D2_IDENTB6             
                aLista[nContar,17] := RECNO() 
             Else

                If Select("T_CODIGO") > 0
                   T_CODIGO->( dbCloseArea() )
                EndIf

                cSql := "SELECT D2_IDENTB6,"
                cSql += "       R_E_C_N_O_ "
                cSql += "  FROM " + RetSqlName("SD2")
                cSql += " WHERE D2_FILIAL  = '" + Alltrim(aLista[nContar,03]) + "'"
                cSql += "   AND D2_DOC     = '" + Alltrim(aLista[nContar,08]) + "'"
                cSql += "   AND D2_SERIE   = '" + Alltrim(aLista[nContar,09]) + "'"
                cSql += "   AND D2_COD     = '" + Alltrim(aLista[nContar,13]) + "'"
                cSql += "   AND D2_IDENTB6 = '" + Alltrim(aLista[nContar,15]) + "'"
                cSql += "   AND D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODIGO", .T., .T. )

                If T_CODIGO->( EOF() )
                   Loop
                Else
                   aLista[nContar,16] := T_CODIGO->D2_IDENTB6                                
                   aLista[nContar,17] := T_CODIGO->R_E_C_N_O_ 
                Endif   

             Endif   
          Endif
       Endif          
   Next nContar

   // ###############################
   // Grava a legenda para display ##
   // ###############################
   For nContar = 1 to Len(aLista)
       If aLista[nContar,15] == aLista[nContar,16]
          aLista[nContar,02] := "2"
       Else
          aLista[nContar,02] := "8"          
       Endif
   Next nContar

   // ################################################# 
   // Filtra os registro comforme status selecionado ##
   // #################################################
   Do Case 
   
      Case Substr(cCOmboBx2,01,01) == "1"

           For nContar = 1 to Len(aLista)
           
               If aLista[nContar,15] == aLista[nContar,16]

                  aAdd( aTransito, { aLista[nContar,01] ,;
                                     aLista[nContar,02] ,;                  
                                     aLista[nContar,03] ,;                  
                                     aLista[nContar,04] ,;                  
                                     aLista[nContar,05] ,;                  
                                     aLista[nContar,06] ,;                  
                                     aLista[nContar,07] ,;                  
                                     aLista[nContar,08] ,;                  
                                     aLista[nContar,09] ,;                  
                                     aLista[nContar,10] ,;                  
                                     aLista[nContar,11] ,;                  
                                     aLista[nContar,12] ,;                  
                                     aLista[nContar,13] ,;                  
                                     aLista[nContar,14] ,;                  
                                     aLista[nContar,15] ,;                  
                                     aLista[nContar,16] ,;                  
                                     aLista[nContar,17] })
               Endif                                     
               
           Next nContar
               
           aLista := {}
           
           For nContar = 1 to Len(aTransito)

                  aAdd( aLista, { aTransito[nContar,01] ,;
                                  aTransito[nContar,02] ,;
                                  aTransito[nContar,03] ,;
                                  aTransito[nContar,04] ,;
                                  aTransito[nContar,05] ,;
                                  aTransito[nContar,06] ,;
                                  aTransito[nContar,07] ,;
                                  aTransito[nContar,08] ,;
                                  aTransito[nContar,09] ,;
                                  aTransito[nContar,10] ,;
                                  aTransito[nContar,11] ,;
                                  aTransito[nContar,12] ,;
                                  aTransito[nContar,13] ,;
                                  aTransito[nContar,14] ,;
                                  aTransito[nContar,15] ,;
                                  aTransito[nContar,16] ,;
                                  aTransito[nContar,17] })
           Next nContar
              
      Case Substr(cCOmboBx2,01,01) == "2"

           For nContar = 1 to Len(aLista)
           
               If aLista[nContar,15] <> aLista[nContar,16]

                  aAdd( aTransito, { aLista[nContar,01] ,;
                                     aLista[nContar,02] ,;                  
                                     aLista[nContar,03] ,;                  
                                     aLista[nContar,04] ,;                  
                                     aLista[nContar,05] ,;                  
                                     aLista[nContar,06] ,;                  
                                     aLista[nContar,07] ,;                  
                                     aLista[nContar,08] ,;                  
                                     aLista[nContar,09] ,;                  
                                     aLista[nContar,10] ,;                  
                                     aLista[nContar,11] ,;                  
                                     aLista[nContar,12] ,;                  
                                     aLista[nContar,13] ,;                  
                                     aLista[nContar,14] ,;                  
                                     aLista[nContar,15] ,;                  
                                     aLista[nContar,16] ,;                  
                                     aLista[nContar,17] })
               Endif                                     
               
           Next nContar
               
           aLista := {}
           
           For nContar = 1 to Len(aTransito)

                  aAdd( aLista, { aTransito[nContar,01] ,;
                                  aTransito[nContar,02] ,;
                                  aTransito[nContar,03] ,;
                                  aTransito[nContar,04] ,;
                                  aTransito[nContar,05] ,;
                                  aTransito[nContar,06] ,;
                                  aTransito[nContar,07] ,;
                                  aTransito[nContar,08] ,;
                                  aTransito[nContar,09] ,;
                                  aTransito[nContar,10] ,;
                                  aTransito[nContar,11] ,;
                                  aTransito[nContar,12] ,;
                                  aTransito[nContar,13] ,;
                                  aTransito[nContar,14] ,;
                                  aTransito[nContar,15] ,;
                                  aTransito[nContar,16] ,;
                                  aTransito[nContar,17] })
           Next nContar
      
   EndCase

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
         	        	       aLista[oList:nAt,17]}}

   oList:Refresh()

Return(.T.)

// #######################################################
// Função que mostra o detalhe do documento selecionado ##
// #######################################################
Static Function MostraDife()

   Local cSql      := ""
   Local cMemo1	   := ""
   Local cString   := ""
   Local lPrimeiro := .T.

   Local oMemo1
   Local oMemo2

   Local kkFilial     := aLista[oList:nAt,03]
   Local kkDocumento  := aLista[oList:nAt,08]
   Local kkSerie      := aLista[oList:nAt,09]   
   Local kkFornecedor := aLista[oList:nAt,04]   
   Local kkLoja       := aLista[oList:nAt,05]      

   Local oFont18 := TFont():New( "Couruer New",,18,,.F.,,,,,.F. )

   Private oDlg

   For nContar = 1 to Len(aLista)

       If aLista[nContar,03] == kkFilial     .And. ;
          aLista[nContar,08] == kkDocumento  .And. ;
          aLista[nContar,09] == kkSerie      .And. ;
          aLista[nContar,04] == kkFornecedor .And. ;
          aLista[nContar,05] == kkLoja

          If lPrimeiro == .T.   

             cString := ""
             cString := "FILIAL.....: " + aLista[nContar,03] + CHR(13) + CHR(10)
             cString += "DOCUMENTO..: " + aLista[nContar,08] + CHR(13) + CHR(10)
             cString += "SÉRIE......: " + aLista[nContar,09] + CHR(13) + CHR(10)
             cString += "FORNECEDOR.: " + aLista[nContar,04] + "." + aLista[nContar,05] + " - " + aLista[nContar,06] + CHR(13) + CHR(10) + CHR(13) + CHR(10)
             cString += "ITEM PRODUTO              DESCRIÇÃO DOS PRODUTOS                             IDENT-SD1  IDENT-SB6 " + CHR(13) + CHR(10)
             cString += "---- -------------------- -------------------------------------------------- ---------- ----------" + CHR(13) + CHR(10)
             lPrimeiro := .F.

          Endif
             
          cString += aLista[nContar,12]               + " "     + ;
                     Substr(aLista[nContar,13],01,20) + " "     + ;
                     Substr(aLista[nContar,14],01,50) + " "     + ;
                     aLista[nContar,16]               + "     " + ;
                     aLista[nContar,15]               + CHR(13) + CHR(10)

       Endif              

   Next nContar

   DEFINE MSDIALOG oDlg TITLE "Detalhes documento poder de terceiros" FROM C(178),C(181) TO C(602),C(896) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1  MEMO Size C(350),C(001) PIXEL OF oDlg

   @ C(035),C(004) GET oMemo2 Var cString MEMO Size C(348),C(157) FONT oFont18 PIXEL OF oDlg

   @ C(196),C(160) Button "Volta" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ######################################################
// Função que crrige o IDENT da SD1 com o IDENT da SB6 ##
// ######################################################
Static Function CorrigeIdent()

   Local cSql        := ""
   Local nContar     := 0
   Local nAcerta     := 0
   Local lMarcado    := .F.
   Local nPosicao    := 0

   Private aProdutos := {}

   // ###################################################
   // Verifica se houve pelo menos um registro marcado ##
   // ###################################################
   lMarcado := .F. 

   For nContar = 1 to Len(aLista)
       If aLista[ncontar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
  
   If lMarcado == .F.
      MsgAlert("Atenção! Nenhum registro foi marcado para ser corrigido. Verifique!")
      Return(.T.)
   Endif

   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif   

       If aLista[nContar,15] <> aLista[nContar,16]
       
          cSql := "" 
          cSql := " UPDATE " + RetSqlName("SD1")
          cSql += "    SET "
          cSql += "       D1_IDENTB6 = '" + Alltrim(aLista[nContar,15]) + "'"
          cSql += " WHERE D1_FILIAL  = '" + aLista[nContar,03] + "'"
          cSql += "   AND D1_DOC     = '" + aLista[nContar,08] + "'"
          cSql += "   AND D1_SERIE   = '" + aLista[nContar,09] + "'"
          cSql += "   AND D1_FORNECE = '" + aLista[nContar,04] + "'"
          cSql += "   AND D1_LOJA    = '" + aLista[nContar,05] + "'"
          cSql += "   AND R_E_C_N_O_ =  " + Alltrim(Str(aLista[nContar,17]))
          cSql += "   AND D_E_L_E_T_ = ''"
             
          _nErro := TcSqlExec(cSql) 

          If TCSQLExec(cSql) < 0 
             alert(TCSQLERROR())
             Return(.T.)
          Endif
          
       Endif   
 
   Next nContar

   // #####################################
   // Atualiza a tela depois da correção ##
   // #####################################
   DifIdent()
      
Return(.T.)

// #######################################
// Função que gera o resultado em Excel ##
// #######################################
Static Function kSaidaExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   AADD(aCabExcel, {"FILIAL"                    , "C", 02, 00 }) // 01
   AADD(aCabExcel, {"FORNECEDOR"                , "C", 06, 00 }) // 02
   AADD(aCabExcel, {"LOJA"                      , "C", 02, 00 }) // 03
   AADD(aCabExcel, {"DESCRIÇÃO DOS FORNECEDORES", "C", 60, 00 }) // 04
   AADD(aCabExcel, {"DATA EMISSÃO"              , "C", 10, 00 }) // 05
   AADD(aCabExcel, {"DOCUMENTO"                 , "C", 09, 00 }) // 06
   AADD(aCabExcel, {"SERIE"                     , "C", 03, 00 }) // 07
   AADD(aCabExcel, {"TES"                       , "C", 03, 00 }) // 08
   AADD(aCabExcel, {"DESCRIÇÃO DAS TES"         , "C", 60, 00 }) // 09
   AADD(aCabExcel, {"ITEM"                      , "C", 04, 00 }) // 10
   AADD(aCabExcel, {"PRODUTO"                   , "C", 30, 00 }) // 11
   AADD(aCabExcel, {"DESCRIÇÃO DOS PRODUTOS"    , "C", 60, 00 }) // 12
   AADD(aCabExcel, {"IDENT SB6"                 , "C", 10, 00 }) // 15 
   AADD(aCabExcel, {"IDENT SD1"                 , "C", 10, 00 }) // 15 
   
   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","PODER DE TERCEIROS COM DIVERGÊNCIAS NO CAMPO D1_IDENTB6 X B6_IDENT", aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, { aLista[nContar,03] ,;
                      aLista[nContar,04] ,;
                      aLista[nContar,05] ,;
                      aLista[nContar,06] ,;
                      aLista[nContar,07] ,;
                      aLista[nContar,08] ,;
                      aLista[nContar,09] ,;
                      aLista[nContar,10] ,;
                      aLista[nContar,11] ,;
                      aLista[nContar,12] ,;
                      aLista[nContar,13] ,;
                      aLista[nContar,14] ,;
                      aLista[nContar,15] ,;
                      aLista[nContar,16] ,;
                      ""                 })

   Next nContar

Return(.T.)