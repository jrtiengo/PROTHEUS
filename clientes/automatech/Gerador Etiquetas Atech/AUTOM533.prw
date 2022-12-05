#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM533.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 30/01/2017                                                          ##
// Objetivo..: Programa que cadastra produtos etiquetas conforme leitura da plani- ##
//             lha lida pelo programa.                                             ## 
// ##################################################################################

User Function AUTOM533()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo8	 := ""

   Local oMemo1
   Local oMemo8

   Private oFont16   := TFont():New( "Courier New",,16,,.f.,,,,.f.,.f. )

   Private cBase	 := ""
   Private cFacas	 := ""
   Private cPapel	 := ""
   Private cTubete   := ""
   Private cSerrilha := ""
   Private cCaracter := ""

   Private oMemo2
   Private oMemo3
   Private oMemo4
   Private oMemo5
   Private oMemo6
   Private oMemo7

   Private aBase     := {}
   Private aFacas    := {}
   Private aPapel    := {}
   Private aTubete   := {}
   Private aSerrilha := {}
   Private aCaracter := {}
   Private aProdutos := {}
   Private aClasseMP := {}
   Private aMPClasse := {}   
   
   Private cComboBx100

   Private lBase     := .F.
   Private lFacas    := .F.
   Private lPapel    := .F.
   Private lTubete   := .F.
   Private lSerrilha := .F.
   Private lCaracter := .F.

   Private tBotaoB   := "Navegar"
   Private tBotaoF   := "Navegar"
   Private tBotaoP   := "Navegar"
   Private tBotaoT   := "Navegar"
   Private tBotaoS   := "Navegar"
   Private tBotaoC   := "Navegar"

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Gerador de Etiquetas Automático" FROM C(178),C(181) TO C(578),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(386),C(001) PIXEL OF oDlg
   @ C(168),C(002) GET oMemo8 Var cMemo8 MEMO Size C(386),C(001) PIXEL OF oDlg

   @ C(031),C(005) Say "Base"           Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(028) Say "Facas"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(133) Say "Papel"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(222) Say "Tubete"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(248) Say "Serrilha"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(274) Say "Característica" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) GET oMemo2 Var cBase     MEMO Size C(019),C(123) PIXEL OF oDlg When lBase
   @ C(041),C(028) GET oMemo3 Var cFacas    MEMO Size C(101),C(123) PIXEL OF oDlg When lFacas
   @ C(041),C(133) GET oMemo4 Var cPapel    MEMO Size C(085),C(123) PIXEL OF oDlg When lPapel
   @ C(041),C(222) GET oMemo5 Var cTubete   MEMO Size C(022),C(123) PIXEL OF oDlg When lTubete
   @ C(041),C(248) GET oMemo6 Var cSerrilha MEMO Size C(022),C(123) PIXEL OF oDlg When lSerrilha
   @ C(041),C(274) GET oMemo7 Var cCaracter MEMO Size C(114),C(123) PIXEL OF oDlg When lCaracter

   @ C(171),C(005) Button "BASE"           Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("B") )
   @ C(171),C(056) Button "FACAS"          Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("F") ) When lChumba
   @ C(171),C(107) Button "PAPEL"          Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("P") ) When !Empty(Alltrim(cBase))
   @ C(171),C(158) Button "TUBETE"         Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("T") ) When !Empty(Alltrim(cPapel))
   @ C(171),C(209) Button "SERRILHA"       Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("S") ) When !Empty(Alltrim(cTubete))
   @ C(171),C(260) Button "CARACTERÍSTICA" Size C(050),C(012) PIXEL OF oDlg ACTION( SelecionaItem("C") ) When !Empty(Alltrim(cSerrilha))

   @ C(185),C(005) Button tBotaoB          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cBase))     ACTION( TrocaBotao(1) )
   @ C(185),C(056) Button tBotaoF          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cFacas))    ACTION( TrocaBotao(2) )
   @ C(185),C(107) Button tBotaoP          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cPapel))    ACTION( TrocaBotao(3) )
   @ C(185),C(158) Button tBotaoT          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cTubete))   ACTION( TrocaBotao(4) )
   @ C(185),C(209) Button tBotaoS          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cSerrilha)) ACTION( TrocaBotao(5) )
   @ C(185),C(260) Button tBotaoC          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cCaracter)) ACTION( TrocaBotao(6) )

   @ C(171),C(312) Button "Estrutura"      Size C(037),C(012) PIXEL OF oDlg ACTION( MATA200() )
   @ C(171),C(351) Button "Configurador"   Size C(037),C(012) PIXEL OF oDlg ACTION( MATA093() )
   @ C(185),C(312) Button "Gerar"          Size C(037),C(012) PIXEL OF oDlg ACTION( GeraEtiquetas() )
   @ C(185),C(351) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
		
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ########################################
// Função que troca os botões de Navegar ##
// ########################################
Static Function TrocaBotao(kBotao)

   Do Case
      Case kBotao == 1
           If lBase
              lBase   := .F.                  
              tBotaoB := "Navegar"
           Else     
              lBase   := .T.                  
              tBotaoB := "Fechar"
           Endif   
      Case kBotao == 2           
           If lFacas 
              lFacas  := .F.                  
              tBotaoF := "Navegar"
           Else   
              lFacas  := .T.                  
              tBotaoF := "Fechar"
           Endif   
      Case kBotao == 3           
           If lPapel 
              lPapel  := .F.                  
              tBotaoP := "Navegar"
           Else   
              lPapel  := .T.                  
              tBotaoP := "Fechar"
           Endif   
      Case kBotao == 4                     
           If lTubete
              lTubete := .F.                  
              tBotaoT := "Navegar"
           Else   
              lTubete := .T.                  
              tBotaoT := "Fechar"
           Endif   
      Case kBotao == 5
           If lSerrilha
              lSerrilha := .F.                  
              tBotaoS   := "Navegar"
           Else   
              lSerrilha := .T.                  
              tBotaoS   := "Fechar"
           Endif   
      Case kBotao == 6
           If lCaracter 
              lCaracter := .F.                  
              tBotaoC   := "Navegar"
           Else
              lCaracter := .T.                  
              tBotaoC   := "Fechar"
           Endif              
   EndCase        

   @ C(185),C(005) Button tBotaoB          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cBase))     ACTION( TrocaBotao(1) )
   @ C(185),C(056) Button tBotaoF          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cFacas))    ACTION( TrocaBotao(2) )
   @ C(185),C(107) Button tBotaoP          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cPapel))    ACTION( TrocaBotao(3) )
   @ C(185),C(158) Button tBotaoT          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cTubete))   ACTION( TrocaBotao(4) )
   @ C(185),C(209) Button tBotaoS          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cSerrilha)) ACTION( TrocaBotao(5) )
   @ C(185),C(260) Button tBotaoC          Size C(050),C(012) PIXEL OF oDlg When !Empty(Alltrim(cCaracter)) ACTION( TrocaBotao(6) )

Return(.T.)

// ###############################################################################################
// Função que abre a janela de seleção de Base, Facas, Papel, Tubete, Serrilha, Características ##
// Os tipos possíveis                                                                           ##
// B - BASE                                                                                     ##
// F - FACA                                                                                     ##
// P - PAPEL                                                                                    ##
// T - TUBETE                                                                                   ##
// S - SERRILHA                                                                                 ##
// C - CARACTERÍSTICA                                                                           ##
// ###############################################################################################
Static Function SelecionaItem(kTipo)

   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1
   
   Private aPesquisa := {"1 - Contendo", "2 - Inciciando", "3 - Exato"}
   Private cString   := Space(60)

   Private cComboBx100
   Private oGet1

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oDlgSEL

   // ###########################################
   // Carrega o array ants de mostrar a janela ##
   // ###########################################
   CarregaAlista(kTipo, 0)

   DEFINE MSDIALOG oDlgSEL TITLE "Cadastro de Facas" FROM C(178),C(181) TO C(614),C(660) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgSEL

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(233),C(001) PIXEL OF oDlgSEL

   Do Case
      Case kTipo == "B"
           @ C(032),C(005) Say "BASE a ser pesquisada"           Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
      Case kTipo == "F"
           @ C(032),C(005) Say "FACA a ser pesquisada"           Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
      Case kTipo == "P"
           @ C(032),C(005) Say "PAPEL a ser pesquisada"          Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
      Case kTipo == "T"
           @ C(032),C(005) Say "TUBETE a ser pesquisada"         Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
      Case kTipo == "S"
           @ C(032),C(005) Say "SERRILHA a ser pesquisada"       Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
      Case kTipo == "C"
           @ C(032),C(005) Say "CARACTERÍSTICA a ser pesquisada" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL
   EndCase           
           
   @ C(032),C(145) Say "Pesquisar por"           Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgSEL

   @ C(041),C(005) MsGet    oGet1       Var   cString   Size C(136),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSEL
   @ C(041),C(145) ComboBox cComboBx100 Items aPesquisa Size C(049),C(010)                              PIXEL OF oDlgSEL

   @ C(038),C(198) Button "Pesquisar"      Size C(037),C(012) PIXEL OF oDlgSEL ACTION( CarregaAlista(kTipo, 1) )
   @ C(203),C(005) Button "Marca Todos"    Size C(050),C(012) PIXEL OF oDlgSEL ACTION( MRegSel(1) )
   @ C(203),C(056) Button "Desmarca Todos" Size C(050),C(012) PIXEL OF oDlgSEL ACTION( MRegSel(2) )
   @ C(203),C(160) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgSEL ACTION( TransfLista(kTipo) )
   @ C(203),C(199) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgSEL ACTION( oDlgSEL:End() )

   @ 070,005 LISTBOX oLista FIELDS HEADER "Mrc"       ,; // 01
                                          "Código"    ,; // 02
                                          "Descrição"  ; // 03
                                         PIXEL SIZE 300,185 OF oDlgSEL ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())      

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                                aLista[oLista:nAt,02]         ,;
          					    aLista[oLista:nAt,03]         }}

   ACTIVATE MSDIALOG oDlgSEL CENTERED 

Return(.T.)

// #####################################################
// Função que marca/desmarca os registros pesquisados ##
// #####################################################
Static Function MRegSel(kTipo)

   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)   

// #############################################################################
// Função que transfere os dados selecionados para a lista conforme parâmetro ##
// #############################################################################
Static Function TransfLista(kTipo)

   Local kLista := ""
   
   Do Case
      Case kTipo == "B"
           kLista := "BASE" 
      Case kTipo == "F"
           kLista := "FACAS" 
      Case kTipo == "P"
           kLista := "PAPEIS" 
      Case kTipo == "T"
           kLista := "TUBETE" 
      Case kTipo == "S"
           kLista := "SERRILHA" 
      Case kTipo == "C"
           kLista := "CARACTERÍSTICAS" 
   EndCase           

   MsgRun("Carregando Lista de " + Alltrim(kLista), "Gerador de Etiquetas Automática",{|| xTransfLista(kTipo) })

Return(.T.)

// #############################################################################
// Função que transfere os dados selecionados para a lista conforme parâmetro ##
// #############################################################################
Static Function xTransfLista(kTipo)

   Local nContar   := 0
   Local nMarcados := 0

   // #####################################################################################################################
   // Se seleção de base, verifica se houve marcação de mais do que um registro. Para Base, somente uma base de cada vez ##
   // #####################################################################################################################
//   If kTipo == "B"
//      nMarcados := 0
//      For nContar = 1 to Len(aLista)
//          If aLista[nContar,01] == .T.
//             nMarcados := nMarcados + 1
//          Endif
//      Next nContar
//      
//      If nMarcados > 1
//         MsgAlert("Somente permitido marcar uma BASE de cada vez.")
//         oDlgSel:End()
//         Return(.T.)
//      Endif
//   Endif             

   Do Case
      Case kTipo == "B"
           aBase     := {}
           cBase     := ""
      Case kTipo == "F"
           aFacas    := {}
           cFacas    := ""
      Case kTipo == "P"
           aPapel    := {}
           cPapel    := ""
      Case kTipo == "T"
           aTubete   := {}
           cTubete   := ""
      Case kTipo == "S"
           aSerrilha := {}
           cSerrilha := ""
      Case kTipo == "C"
           aCaracter := {}
           cCaracter := ""
   EndCase           

   For nContar = 1 to Len(aLista)
   
       If aLista[nContar,01] == .F.
          Loop
       Endif   

       Do Case

          Case kTipo == "B"
               cBase     := cBase     + aLista[nContar,02] + chr(13) + chr(10)
               aAdd( aBase, Alltrim(aLista[nContar,02]) )
          Case kTipo == "F"
               cFacas    := cFacas    + aLista[nContar,02] + "-" + Alltrim(aLista[nContar,03]) + chr(13) + chr(10)
               aAdd( aFacas, Alltrim(U_P_CORTA(T_FACA->BU_CONDICA, '"',2)))
          Case kTipo == "P"
               cPapel    := cPapel    + aLista[nContar,02] + "-" + Alltrim(aLista[nContar,03]) + chr(13) + chr(10)
               aAdd( aPapel, aLista[nContar,02] )
          Case kTipo == "T"
               cTubete   := cTubete   + aLista[nContar,02] + chr(13) + chr(10)
               aAdd( aTubete, aLista[nContar,02] )
          Case kTipo == "S"
               cSerrilha := cSerrilha + aLista[nContar,02] + chr(13) + chr(10)
               aAdd( aSerrilha, aLista[nContar,02] )
          Case kTipo == "C"
               cCaracter := cCaracter + aLista[nContar,02] + "-" + Alltrim(aLista[nContar,03]) + chr(13) + chr(10)
               aAdd( aCaracter, aLista[nContar,02] )
       EndCase

   Next nContar                                

   // ##############################################################
   // Se tipo for Papel, carrega as facas dos papeis selecionados ##
   // ##############################################################
   If kTipo == "P"

      cFacas := ""
      aFacas := {}

      For nContar = 1 to Len(aLista)
   
          If aLista[nContar,01] == .F.
             Loop
          Endif   

          kBase     := Alltrim(StrTran(StrTran(cBase, chr(13), ""), chr(10), ""))
          kPapel    := "PAP" + Space(07) + aLista[nContar,02] + Space(11)
          kCodPapel := aLista[nContar,02]
 
          If Select("T_FACA") > 0
             T_FACA->( dbCloseArea() )
          EndIf

          cSql := "" 
          cSql := "SELECT BU_CONDICA " 
          cSql += "  FROM " + RetSqlName("SBU")
          cSql += " WHERE BU_IDC2 = '" + kPapel + "'"
          cSql += "   AND BU_BASE = '" + kBase  + "'"
          cSql += "   AND D_E_L_E_T_ = ''"
          cSql += " ORDER BY BU_CONDICA  "

   	      cSql := ChangeQuery( cSql )
   	      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FACA", .T., .T. )

          T_FACA->( DbGoTop() )
          
          WHILE !T_FACA->( EOF() )

             // ##########################
             // Consulta o nome da faca ##
             // ##########################
             If Select("T_NOMEFACA") > 0
                T_NOMEFACA->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT BS_CODIGO, BS_DESCPRD" 
             cSql += "  FROM " + RetSqlName("SBS")
             cSql += " WHERE D_E_L_E_T_ = ''"
             cSql += "   AND BS_CODIGO  = '" + Alltrim(U_P_CORTA(T_FACA->BU_CONDICA, '"',2)) + "'"
             cSql += "   AND BS_BASE    = '" + Alltrim(kBase) + "'"

    	     cSql := ChangeQuery( cSql )
   	         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOMEFACA", .T., .T. )

             cFacas := cFacas + Alltrim(aLista[nContar,02]) + " - " + U_P_CORTA(T_FACA->BU_CONDICA, '"',2) + " - " + Alltrim(T_NOMEFACA->BS_DESCPRD) + CHR(13) + CHR(10) 

             aAdd( aFacas, { kCodPapel, U_P_CORTA(T_FACA->BU_CONDICA, '"',2) })

             T_FACA->( DbSkip() )

          ENDDO

      Next nContar                                
      
   Endif

   oDlgSEL:End() 

Return(.T.)

// ########################################################
// Função que carrega o array aLista conforme parâmetros ##
// ########################################################
Static Function CarregaAlista(kTipo, kJanela)

   Local cTexto := ""

   Do Case
      Case kTipo == "B"
           cTexto := "Aguarde! Pesquisando BASE ..."
      Case kTipo == "F"
           cTexto := "Aguarde! Pesquisando FACA ..."
      Case kTipo == "P"
           cTexto := "Aguarde! Pesquisando PAPEL ..."
      Case kTipo == "T"
           cTexto := "Aguarde! Pesquisando TUBETE ..."
      Case kTipo == "S"
           cTexto := "Aguarde! Pesquisando SERRILHA ..."
      Case kTipo == "C"
           cTexto := "Aguarde! Pesquisando CARACTERÍSTICA ..."
   EndCase           

   MsgRun(cTexto, "Gerador Etiquetas",{|| xCarregaAlista(kTipo, kJanela) })

Return(.T.)

// ########################################################
// Função que carrega o array aLista conforme parâmetros ##
// ########################################################
Static Function xCarregaAlista(kTipo, kJanela)

   aLista := {}

   // ######################################################
   // Carrega o array conforme o tipo passado no parâmtro ##
   // ######################################################
   Do Case

      // ###################
      // Carrega as Bases ##
      // ###################
      Case kTipo == "B"
      
           If Select("T_BASE") > 0
              T_BASE->( dbCloseArea() )
           EndIf

           cSql := "" 
           cSql := "SELECT BS_BASE "
           cSql += "  FROM " + RetSqlName("SBS")
           cSql += " WHERE D_E_L_E_T_ = ''"

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BS_BASE LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BS_BASE LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " GROUP BY BS_BASE"
           cSql += " ORDER BY BS_BASE"      

     	   cSql := ChangeQuery( cSql )
     	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )

           T_BASE->( DbGoTop() )
           
           WHILE !T_BASE->( EOF() )
              aAdd( aLista, { .F., T_BASE->BS_BASE, "" })
              T_BASE->( DbSkip() )
           ENDDO
              
      // ###################
      // Carrega as Facas ##
      // ###################
      Case kTipo == "F"
      
           If Select("T_FACA") > 0
              T_FACA->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT BS_CODIGO, BS_DESCPRD" 
           cSql += "  FROM " + RetSqlName("SBS")
           cSql += " WHERE D_E_L_E_T_ = ''"

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BS_DESCPRD LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BS_DESCPRD LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " GROUP BY BS_CODIGO, BS_DESCPRD  "
           cSql += " ORDER BY BS_CODIGO  "

   	       cSql := ChangeQuery( cSql )
	       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FACA", .T., .T. )

           T_FACA->( DbGoTop() )
           
           WHILE !T_FACA->( EOF() )
              aAdd( aLista, { .F., Alltrim(T_FACA->BS_CODIGO), T_FACA->BS_DESCPRD  })
              T_FACA->( DbSkip() )
           ENDDO
              
      // ####################
      // Carrega os Papeis ##
      // ####################
      Case kTipo == "P"

           If Empty(Alltrim(cBase))
              MsgAlert("Necessário selecionar BASE.")
              aAdd( aLista, { .F., "", "" })
              oDlgSEL:End()
              Return(.T.)
           Endif   

           If Select("T_PAPEL") > 0
              T_PAPEL->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT BX_CODOP, BX_DESCPR "
           cSql += "  FROM " + RetSqlName("SBX")
           cSql += " WHERE BX_CONJUN  = 'PAP'"
           cSql += "   AND D_E_L_E_T_ = ''   "

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " ORDER BY BX_CODOP      "
 
      	   cSql := ChangeQuery( cSql )
	       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PAPEL", .T., .T. )

           T_PAPEL->( DbGoTop() )
           
           WHILE !T_PAPEL->( EOF() )
              aAdd( aLista, { .F., T_PAPEL->BX_CODOP, T_PAPEL->BX_DESCPR })
              T_PAPEL->( DbSkip() )
           ENDDO

      // #####################
      // Carrega os Tubetes ##
      // #####################
      Case kTipo == "T"

           If Select("T_TUBETE") > 0
              T_TUBETE->( dbCloseArea() )
           EndIf

           cSql := "" 
           cSql := "SELECT BX_CODOP, BX_DESCPR "
           cSql += "  FROM " + RetSqlName("SBX")
           cSql += " WHERE BX_CONJUN  = 'TUB'"
           cSql += "   AND D_E_L_E_T_ = ''   "

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " ORDER BY BX_CODOP      "

      	   cSql := ChangeQuery( cSql )
     	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TUBETE", .T., .T. )

           T_TUBETE->( DbGoTop() )
           
           WHILE !T_TUBETE->( EOF() )
              aAdd( aLista, { .F., T_TUBETE->BX_DESCPR, "" })
              T_TUBETE->( DbSkip() )
           ENDDO

      // #######################
      // Carrega as Serrilhas ##
      // #######################
      Case kTipo == "S"

           If Select("T_SERRILHA") > 0
              T_SERRILHA->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT BX_CODOP, BX_DESCPR "
           cSql += "  FROM " + RetSqlName("SBX")
           cSql += " WHERE BX_CONJUN  = 'SER'"
           cSql += "   AND D_E_L_E_T_ = ''   "

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " ORDER BY BX_CODOP      "

     	   cSql := ChangeQuery( cSql )
    	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERRILHA", .T., .T. )

           T_SERRILHA->( DbGoTop() )
           
           WHILE !T_SERRILHA->( EOF() )
              aAdd( aLista, { .F., T_SERRILHA->BX_DESCPR, "" })
              T_SERRILHA->( DbSkip() )
           ENDDO

      // #############################
      // Carrega as Características ##
      // #############################
      Case kTipo == "C"

           If Select("T_CARACTE") > 0
              T_CARACTE->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT BX_CODOP, BX_DESCPR "
           cSql += "  FROM " + RetSqlName("SBX")
           cSql += " WHERE BX_CONJUN  = 'CAR'"
           cSql += "   AND D_E_L_E_T_ = ''   "

           If Empty(Alltrim(cString))
           Else
              Do Case
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '%" + Alltrim(cString) + "%'"
                 Case Substr(cComboBx100,01,01) == "1"
                      cSql += " AND BX_DESCPR LIKE '" + Alltrim(cString) + "%'"
              EndCase
           Endif                         

           cSql += " ORDER BY BX_CODOP      "

      	   cSql := ChangeQuery( cSql )
     	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARACTE", .T., .T. )

           T_CARACTE->( DbGoTop() )
           
           WHILE !T_CARACTE->( EOF() )
              aAdd( aLista, { .F., T_CARACTE->BX_CODOP, T_CARACTE->BX_DESCPR })
              T_CARACTE->( DbSkip() )
           ENDDO

   EndCase

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "" } )
   Endif   

   If kJanela == 0
      Return(.T.)
   Endif   

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02]         ,;
           					    aLista[oLista:nAt,03]         }}

Return(.T.)          					   

// #####################################
// Função que gera as novas etiquetas ##
// #####################################
Static Function GeraEtiquetas()

   MsgRun("Geradando Simulação de Novas Etiquetas ...", "Gerador de Etiquetas",{|| xGeraEtiquetas() })

Return(.T.)

// #####################################
// Função que gera as novas etiquetas ##
// #####################################
Static Function xGeraEtiquetas()

   Local lChumba     := .F.

   Local cMemo1      := ""
   Local oMemo1

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local nSepara     := 0
   Local j           := ""
   Local aDados      := {} 
    
   Local xBase       := 0
   Local xPapel      := 0
   Local xFacas      := 0
   Local xTubete     := 0
   Local xSerrilha   := 0
   Local xCaracter   := 0

   Private nPosi01   := 0
   Private nPosi02   := 0
   Private lVolta    := .F.
   Private aConsulta := {}
   Private aNaoFez   := {}

   Private lVoltaClasse := .T.

   Private aBrowse   := {}
   Private oBrowse

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

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

   Private oDlgINC

   Private lMsErroAuto := .F. 


   If Len(aBase) == 0
      MsgAlert("Base a serem utilizadas não selecionadas.")
      Return(.T.)
   Endif   

   If Len(aFacas) == 0
      MsgAlert("Facas a serem utilizadas não selecionadas.")
      Return(.T.)
   Endif   
   
   If Len(aPapel) == 0   
      MsgAlert("Papeis a serem utilizados não selecionados.")
      Return(.T.)
   Endif   
   
   If Len(aTubete) == 0
      MsgAlert("Tubetes a serem utilizados não selecionados.")
      Return(.T.)
   Endif   
   
   If Len(aSerrilha) == 0
      MsgAlert("Serrilhas a serem utilizadas não selecionadas.")
      Return(.T.)
   Endif   

   If Len(aCaracter) == 0
      MsgAlert("Características a serem utilizadas não selecionadas.")
      Return(.T.)
   Endif   

   // ##########################################################################################
   // Envia para a função que solicita a classe mp dos papeis antes da inclusão das etiquetas ##
   // ##########################################################################################
   lVoltaClasse := .T.
   
   ClasseMP()

   If lVoltaClasse == .T.
      Return(.T.)
   Endif   

   // ##############################################################
   // Realiza a inclusão dos produtos conforme dados selecionados ##
   // ##############################################################

   // #######
   // Base ##
   // #######
   For xBase = 1 to Len(aBase)

       // ######## 
       // Papel ##
       // ########
       For xPapel = 1 to Len(aPapel)

           // ########
           // Facas ##
           // ########
           For xFacas = 1 to Len(aFacas)

               If aFacas[xFacas,01] <> aPapel[xPapel]
                  Loop
               Endif   

               // ######### 
               // Tubete ##
               // #########
               For xTubete = 1 to Len(aTubete)

                   // ###########
                   // Serrilha ##
                   // ###########
                   For xSerrilha = 1 to Len(aSerrilha)

                       // #################
                       // Característica ##
                       // #################
                       For xCaracter = 1 to Len(aCaracter)
                       
                           // ###########################
                           // Pesquisa o nome do papel ##
                           // ###########################
                           If Select("T_PAPEL") > 0
                              T_PAPEL->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT BX_DESCPR "
                           cSql += "  FROM " + RetSqlName("SBX")
                           cSql += " WHERE BX_CONJUN  = 'PAP'"
                           cSql += "   AND BX_CODOP   = '" + Alltrim(aPapel[xPapel]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

                       	   cSql := ChangeQuery( cSql )
    	                   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PAPEL", .T., .T. )

                           // ##########################
                           // Pesquisa o nome da Faca ##
                           // ##########################
                           If Select("T_FACA") > 0
                              T_FACA->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT BX_DESCPR "
                           cSql += "  FROM " + RetSqlName("SBX")
                           cSql += " WHERE BX_CONJUN  = 'FAC'"
                           cSql += "   AND BX_CODOP   = '" + Alltrim(aFacas[xFacas,02]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

                       	   cSql := ChangeQuery( cSql )
    	                   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FACA", .T., .T. )

                           // ##############################
                           // Pesquisa o código do Tubete ##
                           // ##############################
                           If Select("T_TUBETE") > 0
                              T_TUBETE->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT BX_CODOP, BX_DESCPR"
                           cSql += "  FROM " + RetSqlName("SBX")
                           cSql += " WHERE BX_CONJUN = 'TUB'"
                           cSql += "   AND BX_DESCPR = '" + Alltrim(aTubete[xTubete]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

   	                       cSql := ChangeQuery( cSql )
	                       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TUBETE", .T., .T. )

                           // #############################
                           // Pesquisa o nome do serilha ##
                           // #############################
                           If Select("T_SERRILHA") > 0
                              T_SERRILHA->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT BX_CODOP, BX_DESCPR "
                           cSql += "  FROM " + RetSqlName("SBX")
                           cSql += " WHERE BX_CONJUN  = 'SER'"
                           cSql += "   AND BX_DESCPR  = '" + Alltrim(aSerrilha[xSerrilha]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

   	                       cSql := ChangeQuery( cSql )
                      	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERRILHA", .T., .T. )

                           // ####################################
                           // Pesquisa o nome do caracteristica ##
                           // ####################################
                           If Select("T_CARACTER") > 0
                              T_CARACTER->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT BX_DESCPR "
                           cSql += "  FROM " + RetSqlName("SBX")
                           cSql += " WHERE BX_CONJUN  = 'CAR'"
                           cSql += "   AND BX_CODOP   = '" + Alltrim(aCaracter[xCaracter]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

             	           cSql := ChangeQuery( cSql )
	                       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARACTER", .T., .T. )

                           // ##################################################
                           // Elabora o código e a descrição da nova etiqueta ##
                           // ##################################################
                           kCodigo    := Alltrim(aBase[xBase])         + ;
                                         Alltrim(aFacas[xFacas,02])    + ;
                                         Alltrim(aPapel[xPapel])       + ;
                                         Alltrim(T_TUBETE->BX_CODOP)   + ;
                                         Alltrim(T_SERRILHA->BX_CODOP) + ;
                                         Alltrim(aCaracter[xCaracter])

                           kDescricao := "ET"                           + " " + ;
                                         Alltrim(T_FACA->BX_DESCPR)     + " " + ;
                                         Alltrim(T_PAPEL->BX_DESCPR)    + " " + ;
                                         Alltrim(T_TUBETE->BX_DESCPR)   + " " + ;
                                         Alltrim(T_SERRILHA->BX_DESCPR) + " " + ;
                                         Alltrim(T_CARACTER->BX_DESCPR)

                           kDesc01   := "ET"                            + " " + ;
                                         Alltrim(T_FACA->BX_DESCPR)     + " " + ;
                                         Alltrim(T_PAPEL->BX_DESCPR)    
                                         
                           kDesc02   :=  Alltrim(T_TUBETE->BX_DESCPR)   + " " + ;
                                         Alltrim(T_SERRILHA->BX_DESCPR) + " " + ;
                                         Alltrim(T_CARACTER->BX_DESCPR)


                           kPeso        := 0
                           kAltura      := 0
                           kLargura     := 0
                           kComprimento := 0
                           kUnidade     := IIF(aBase[xBase] == "02", "MI", "RL")

                           // ###############################
                           // Pesquisa a altura do produto ##
                           // ###############################
                           If Select("T_ALTURA") > 0
                              T_ALTURA->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT LTRIM(RTRIM(BX_DESCPR)) + '/' AS ALTURA"
                           cSql += "  FROM " + RetSqlName("SBX") 
                           cSql += " WHERE BX_CONJUN = 'PAP'"
                           cSql += "   AND BX_CODOP   = '" + Alltrim(aPapel[xPapel]) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

             	           cSql := ChangeQuery( cSql )
	                       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ALTURA", .T., .T. )
                                                              
                           If T_ALTURA->( EOF() )
                              kAltura := 0                                                 
                           Else
                              kAltura := VAL(U_P_CORTA(Alltrim(T_ALTURA->ALTURA), "/", 2)) / 10
                           Endif

                           // ####################
                           // Carrega a Legenda ##
                           // ####################
                           If Select("T_LEGENDA") > 0
                              T_LEGENDA->( dbCloseArea() )
                           EndIf

                           cSql := ""       
                           cSql := "SELECT B1_COD "
                           cSql += "  FROM " + RetSqlName("SB1")
                           cSql += " WHERE B1_COD     = '" + Alltrim(kCodigo) + "'"
                           cSql += "   AND D_E_L_E_T_ = ''"

   	                       cSql := ChangeQuery( cSql )
	                       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LEGENDA", .T., .T. )

                           If T_LEGENDA->( EOF() )
                              kLegenda := "2"
                           Else
                              kLegenda := "8"                              
                           Endif   

                           aAdd( aBrowse, {.F.                     ,; // 01 - Marcação
                                           kLegenda                ,; // 02 - Legenda
                                           kCodigo                 ,; // 03 - Código do Produto
                                           kCodigo                 ,; // 04 - Código de Barras
                                           kDescricao              ,; // 05 - Descrição Principal
                                           "017"                   ,; // 06 - Grupo Tributário do Produto
                                           "0201"                  ,; // 07 - Grupo do Produto
                                           "01"                    ,; // 08 - Local de Armazenamento
                                           "000329"                ,; // 09 - Código do Fabricante
                                           "004"                   ,; // 10 - Loja do Fabricante
                                           "06"                    ,; // 11 - Classe do Produto
                                           "01"                    ,; // 12 - Operad ???
                                           "0"                     ,; // 13 - Origem do Produto
                                           "48219000"              ,; // 14 - NCM
                                           1                       ,; // 15 - SB1->B1_QB
                                           "PA"                    ,; // 16 - Tipo de Produto
                                           kUnidade                ,; // 17 - Unidade de Medida
                                           "2"                     ,; // 18 - Garantia
                                           "S"                     ,; // 19 - Indica que produto será enviado a loja virtual
                                           "N"                     ,; // 20 - Indica que produto não é controlado por número de série
                                           kPeso                   ,; // 21 - Peso
                                           kAltura                 ,; // 22 - Altura
                                           kLargura                ,; // 23 - Largura
                                           kComprimento            ,; // 24 - Comprimento
                                           kDesc01                 ,; // 25 - Descrição 01 do Produto
                                           kDesc02                 }) // 26 - Descrição 02 do Produto                                           
  
                       Next xCaracter

                   Next xSerrilha

               Next xTubete

           Next xFacas

       Next xPapael

   Next xBase
   
   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgINC TITLE "Gerador de Etiquetas Automático" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgINC
   @ C(212),C(126) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlgINC
   @ C(212),C(210) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlgINC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlgINC

   @ C(212),C(135) Say "Produtos já cadastrados"      Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgINC
   @ C(212),C(220) Say "Produtos a serem cadastrados" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgINC

   @ C(210),C(005) Button "Marca Todos"    Size C(056),C(012) PIXEL OF oDlgINC ACTION( MProduto(1) )
   @ C(210),C(064) Button "Desmarca Todos" Size C(056),C(012) PIXEL OF oDlgINC ACTION( MProduto(2) )
   @ C(210),C(422) Button "Incluir"        Size C(037),C(012) PIXEL OF oDlgINC ACTION( IncluiNVEtq() )
   @ C(210),C(461) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgINC ACTION( FECHATEL() )

   aAdd( aBrowse, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   @ 047,005 LISTBOX oBrowse FIELDS HEADER "Mrc"                 ,; // 01
                                           "Leg"                 ,; // 02
                                           "Código"              ,; // 03
                                           "Código Barras"       ,; // 04
                                           "Descrição Produtos"  ,; // 05
                                           "Grupo Tributário"    ,; // 06
                                           "Grupo do Produto"    ,; // 07
                                           "Local"               ,; // 08
                                           "Fabricante"          ,; // 09
                                           "Loja"                ,; // 10
                                           "Classe MP"           ,; // 11
                                           "Rot.Op.Padrão"       ,; // 12
                                           "Origem Produto"      ,; // 13
                                           "NCM"                 ,; // 14
                                           "QTD Base Estrutura"  ,; // 15
                                           "Tipo Produto"        ,; // 16
                                           "Unid. Medida"        ,; // 17
                                           "Garantia"            ,; // 18
                                           "Loja Virtual"        ,; // 19
                                           "Nº de Série"         ,; // 20
                                           "Peso"                ,; // 21
                                           "Altura"              ,; // 22
                                           "Largura"             ,; // 23
                                           "Comprimento"          ; // 24
                                           PIXEL SIZE 633,218 OF oDlgINC ON dblClick(aBrowse[oBrowse:nAt,1] := !aBrowse[oBrowse:nAt,1],oBrowse:Refresh())     

   oBrowse:SetArray( aBrowse )

   oBrowse:bLine := {||     {Iif(aBrowse[oBrowse:nAt,01],oOk,oNo),;
                              If(aBrowse[oBrowse:nAt,02] == "0", oBranco   ,;
                              If(aBrowse[oBrowse:nAt,02] == "2", oVerde    ,;
                              If(aBrowse[oBrowse:nAt,02] == "3", oCancel   ,;                         
                              If(aBrowse[oBrowse:nAt,02] == "1", oAmarelo  ,;                         
                              If(aBrowse[oBrowse:nAt,02] == "5", oAzul     ,;                         
                              If(aBrowse[oBrowse:nAt,02] == "6", oLaranja  ,;                         
                              If(aBrowse[oBrowse:nAt,02] == "7", oPreto    ,;                         
                              If(aBrowse[oBrowse:nAt,02] == "8", oVermelho ,;
                              If(aBrowse[oBrowse:nAt,02] == "9", oPink     ,;
                              If(aBrowse[oBrowse:nAt,02] == "4", oEncerra, "")))))))))),;
                                 aBrowse[oBrowse:nAt,03],;
                                 aBrowse[oBrowse:nAt,04],;
                                 aBrowse[oBrowse:nAt,05],;
                                 aBrowse[oBrowse:nAt,06],;
                                 aBrowse[oBrowse:nAt,07],;
                                 aBrowse[oBrowse:nAt,08],;                                 
                                 aBrowse[oBrowse:nAt,09],;
                                 aBrowse[oBrowse:nAt,10],;
                                 aBrowse[oBrowse:nAt,11],;
                                 aBrowse[oBrowse:nAt,12],;
                                 aBrowse[oBrowse:nAt,13],;
                                 aBrowse[oBrowse:nAt,14],;                                 
                                 aBrowse[oBrowse:nAt,15],;
                                 aBrowse[oBrowse:nAt,16],;
                                 aBrowse[oBrowse:nAt,17],;
                                 aBrowse[oBrowse:nAt,18],;
                                 aBrowse[oBrowse:nAt,19],;
                                 aBrowse[oBrowse:nAt,20],;                                 
                                 aBrowse[oBrowse:nAt,21],;
                                 aBrowse[oBrowse:nAt,22],;
                                 aBrowse[oBrowse:nAt,23],;
                                 aBrowse[oBrowse:nAt,24]}}

   oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}

   ACTIVATE MSDIALOG oDlgINC CENTERED 

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// ##########################################################
// Função que marca/desmarca os produtos a serem incçuídos ##
// ##########################################################
Static Function mProduto(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aBrowse)

       If kTipo == 1
          If aBrowse[nContar,02] == "8"
             aBrowse[nContar,01] := .F.
          Else
             aBrowse[nContar,01] := .T.             
          Endif
      Else
         aBrowse[nContar,01] := .F.                          
      Endif
  Next nContar       

Return(.T.)

// ###############################################################
// Função que fecha a janela de visualização dos novos produtos ##
// ###############################################################
Static Function FechaTel()

   cBase	 := ""
   cFacas	 := ""
   cPapel	 := ""
   cTubete   := ""
   cSerrilha := ""
   cCaracter := ""

   oDlgINC:End()
   
Return(.T.)   

// ####################################################
// Função que inclui os novos produtos na tabela SB1 ##
// ####################################################
Static Function IncluiNVEtq()

   MsgRun("Aguarde! Incluindo novos produtos ...", "Gerador de Etiquetas",{|| xIncluiNVEtq() })

Return(.T.)

// ####################################################
// Função que inclui os novos produtos na tabela SB1 ##
// ####################################################
Static Function xIncluiNVEtq()

   Local nContar   := 0
   Local lMarcados := .F.
   Local nEtqRol   := 0
   Local nRolos    := 0
   
   // #####################################################################
   // Verifica se houve pelo menos um registro selecionado para inclusão ##
   // #####################################################################
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar                                                                                   

   For nContar = 1 to Len(aBrowse)
   
       If aBrowse[nContar,01] == .F.
          Loop
       Endif   

       If aBrowse[nContar,02] == "8"
          Loop
       Endif   

       // ##############################################
       // Inclui a estrutura do produto na tabela SG1 ##
       // ##############################################
       If Select("T_ESTRUTURA") > 0
          T_ESTRUTURA->( dbCloseArea() )
       EndIf

       xxPapel := "'PAP       " + Substr(aBrowse[nContar,03],07,03) + "'"
       xxFaca  := "'@FAC == " + '"' + Substr(aBrowse[nContar,03],03,04) + '"' + "'"

       cSql := ""
       cSql := "SELECT BU_OK	 ,"
       cSql += "       BU_FILIAL ,"
       cSql += "       BU_BASE	 ,"
       cSql += "       BU_IDC1	 ,"
       cSql += "       BU_IDC2	 ,"
       cSql += "       BU_COMP	 ,"
       cSql += "       BU_QUANT	 ,"
       cSql += "       BU_CONDICA,"
       cSql += "       BU_FORMSHK,"
       cSql += "       BU_OBS	 ,"
       cSql += "       BU_INI	 ,"
       cSql += "       BU_FIM	 ,"
       cSql += "       BU_POTENCI,"
       cSql += "       BU_PERDA	 ,"
       cSql += "       BU_TRT	 ,"
       cSql += "       BU_TIPVEC ,"
       cSql += "       BU_VECTOR ,"
       cSql += "       BU_GROPC	 ,"
       cSql += "       BU_OPC	  "
       cSql += "  FROM " + RetSqlName("SBU")
       cSql += " WHERE LTRIM(RTRIM(BU_IDC2))    = " + xxPapel
       cSql += "   AND LTRIM(RTRIM(BU_CONDICA)) = " + xxFaca
       cSql += "   AND D_E_L_E_T_ = ''" 

	   cSql := ChangeQuery( cSql )
   	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTRUTURA", .T., .T. )

       If T_ESTRUTURA->( EOF() )
       Else

          // ########################################################################
          // Verifica se a estrutura para o produto existe. Se não existir, inclui ##
          // ########################################################################
          kk_Codigo := Alltrim(aBrowse[nContar,03]) + Space(30 - Len(Alltrim(aBrowse[nContar,03])))

		  DbSelectArea("SG1")
		  DbSetOrder(1)
		  If DbSeek(xFilial("SG1") + aBrowse[nContar,03] + T_ESTRUTURA->BU_COMP + T_ESTRUTURA->BU_TRT)
		  Else
             dbSelectArea("SG1")
             RecLock("SG1",.T.)
             SG1->G1_COD     := aBrowse[nContar,03]
             SG1->G1_COMP	 := T_ESTRUTURA->BU_COMP
             SG1->G1_TRT	 := T_ESTRUTURA->BU_TRT
             SG1->G1_QUANT   := T_ESTRUTURA->BU_QUANT
             SG1->G1_PERDA   := T_ESTRUTURA->BU_PERDA
             SG1->G1_INI     := CTOD(SUBSTR(T_ESTRUTURA->BU_INI,07,02) + "/" +SUBSTR(T_ESTRUTURA->BU_INI,05,02) + "/" + SUBSTR(T_ESTRUTURA->BU_INI,01,04))
             SG1->G1_FIM	 := CTOD(SUBSTR(T_ESTRUTURA->BU_FIM,07,02) + "/" +SUBSTR(T_ESTRUTURA->BU_FIM,05,02) + "/" + SUBSTR(T_ESTRUTURA->BU_FIM,01,04))
             SG1->G1_FIXVAR  := "V"
             SG1->G1_REVFIM  := "ZZZ"
             SG1->G1_NIV	 := "01"
             SG1->G1_NIVINV  := "99"
             SG1->G1_POTENCI := T_ESTRUTURA->BU_POTENCI
             SG1->G1_VLCOMPE := "N"
             MsUnLock()          
          Endif   
       Endif

       // ################################################
       // Calcula as dimensões do produto para gravação ##
       // ################################################
       kAltura      := aBrowse[nContar,22]
       kRaio        := 0
       kPeso        := 0
       kComprimento := 0
       kLargura     := 0
      
       // ##############################   
       // Pesquisa o Raio da etiqueta ##
       // ##############################
       If Alltrim(Substr(aBrowse[nContar,03],01,02)) == "02"

          Do Case
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "2"
                  kRaio := 4.60
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "4"
                  kRaio := 9
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "1"
                  kRaio := 2.55
             Otherwise
                  kRaio := 0
          EndCase
	
       Else

          kRaio := IIF(Alltrim(Substr(aBrowse[nContar,03],10,01)) == "2", 4.25, 8)         

          Do Case
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "2"
                  kRaio := 4.25
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "4"
                  kRaio := 8
             Case Alltrim(Substr(aBrowse[nContar,03],10,01)) == "1"
                  kRaio := 2.55
             Otherwise
                  kRaio := 0
          EndCase

       Endif                                                  
       
       // ################################################
       // Pesquisa a Classe MP do produto para inclusão ##
       // ################################################
       kkClasse := Space(02)
       For xClasse = 1 to Len(aMPClasse)
           If aMPClasse[xClasse,01] == Substr(aBrowse[nContar,03],07,03)
              kkClasse := aMPClasse[xClasse,02]
              Exit
           Endif
       Next xClasse       

       // #########################
       // Inclui a nova etiqueta ##
       // #########################
       dbSelectArea("SB1")
       RecLock("SB1",.T.)
       SB1->B1_COD     := aBrowse[nContar,03]
       SB1->B1_CODBAR  := aBrowse[nContar,03]
//     SB1->B1_DESC    := Substr(aBrowse[nContar,05],01,25)
//     SB1->B1_DAUX    := Alltrim(Substr(aBrowse[nContar,05],26))
       SB1->B1_DESC    := Alltrim(aBrowse[nContar,25])
       SB1->B1_DAUX    := Alltrim(aBrowse[nContar,26])
       SB1->B1_GRTRIB  := aBrowse[nContar,06]
       SB1->B1_GRUPO   := aBrowse[nContar,07]
       SB1->B1_LOCPAD  := aBrowse[nContar,08]
       SB1->B1_PROC    := aBrowse[nContar,09]
       SB1->B1_LOJPROC := aBrowse[nContar,10]
       SB1->B1_MPCLAS  := kkClasse
       SB1->B1_OPERPAD := aBrowse[nContar,12]
       SB1->B1_ORIGEM  := aBrowse[nContar,13]
       SB1->B1_POSIPI  := aBrowse[nContar,14]
       SB1->B1_QB      := aBrowse[nContar,15]
       SB1->B1_TIPO    := aBrowse[nContar,16]
       SB1->B1_UM      := aBrowse[nContar,17]
       SB1->B1_GARANT  := aBrowse[nContar,18]
       SB1->B1_ZVIR    := aBrowse[nContar,19]
       SB1->B1_LOCALIZ := aBrowse[nContar,20]
       SB1->B1_PESC    := 0
       SB1->B1_ALTU    := kAltura
       SB1->B1_EMBA    := "3"            
       SB1->B1_RAIO    := kRaio
       SB1->B1_ZVIN    := "N"
       //ATUALIZAÇÃO REALIZADA POR SOSYS
       SB1->B1_PIS	   := "2" 
       SB1->B1_CSLL	   := "2"	            
       SB1->B1_COFINS  := "2"	
       //FIM ATUALIZACAO
       MsUnLock()

       // #############################################
       // Pesquisa a quantidade de rolo por etiqueta ##
       // #############################################
       _aRet1 := U_CALCMETR(aBrowse[nContar,03])

       nEtqRol := _aRet1[2]
       nRolos  := nEtqRol

       // #############################
       // Calcula o peso da etiqueta ##
       // #############################          
       If Select("T_PESO") > 0
          T_PESO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT G1_COD  ,"
       cSql += "       G1_QUANT,"
       cSql += "	  (G1_QUANT * 0.14763) AS PESO"
       cSql += "  FROM " + RetSqlName("SG1")
       cSql += " WHERE G1_COD     = '" + Alltrim(aBrowse[nContar,03]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESO", .T., .T. )

       If T_PESO->( EOF() )
          kPeso := 0
       Else
          kPeso := T_PESO->PESO
       Endif

       kPeso := Round((nEtqRol * kPeso) / 1000,2)

       // ######################################
       // Atualiza o peso do produto incluído ##
       // ######################################
   	   DbSelectArea("SB1")
	   DbSetOrder(1) // B1_FILIAL+B1_COD
	   If DbSeek(xFilial("SB1") + aBrowse[nContar,03])
          RecLock("SB1",.F.)
          SB1->B1_PESC   := kPeso
          SB1->B1_QROLOS := nRolos
          MsUnLock()
       Endif   

   Next nContar

   MsgAlert("Inclusão dos produtos realizada com sucesso.")

   cBase	 := ""
   cFacas	 := ""
   cPapel	 := ""
   cTubete   := ""
   cSerrilha := ""
   cCaracter := ""

   oDlgINC:End()

Return(.T.)

// ##################################
// Função que solicita a classe MP ##
// ##################################
Static Function ClasseMP()

   Local lChumba  := .F.
   Local nContar  := 0
   Local cMemo1	  := ""
   Local cMemo2	  := ""

   Local oMemo1
   Local oMemo2

   Private cClasse  := Space(02)
   Private oGet1

   Private oDlgClasse

   // ##########################
   // Carrega o array aPapeis ##
   // ##########################
   aClasseMP := {}  
   aMPClasse := {}

   kPapeis := Strtran(Strtran(cPapel, chr(13), "|"), chr(10), "")
   
   For nContar = 1 to U_P_OCCURS(kPapeis, "|", 1)
       aAdd( aClasseMP, U_P_CORTA(kpapeis, "|", nContar) )
       aAdd( aMPClasse, { Alltrim(U_P_CORTA(U_P_CORTA(kpapeis, "|", nContar), "-", 1)), "" } )
   Next nContar    

   DEFINE MSDIALOG oDlgClasse TITLE "Gerador Etiquetas Autoomática" FROM C(178),C(181) TO C(369),C(543) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlgClasse

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(174),C(001) PIXEL OF oDlgClasse
   @ C(076),C(002) GET oMemo2 Var cMemo2 MEMO Size C(174),C(001) PIXEL OF oDlgClasse
      
   @ C(032),C(005) Say "Papeis" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgClasse
   @ C(053),C(005) Say "Classe MP por Papel" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgClasse
   
   @ C(041),C(005) ComboBox cComboBx100 Items aClasseMP Size C(171),C(010)                              PIXEL OF oDlgClasse ON CHANGE ALTERACLASSE()
   @ C(062),C(005) MsGet    oGet1       Var   cClasse   Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgClasse F3("SX5","ZP")

   @ C(080),C(033) Button "Confirma"  Size C(037),C(012) PIXEL OF oDlgClasse ACTION( ConfirmaMP () )
   @ C(080),C(071) Button "Processar" Size C(037),C(012) PIXEL OF oDlgClasse ACTION( FechaMP() )
   @ C(080),C(110) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgClasse ACTION( lVoltaClasse == .T., oDlgClasse:End() )

   ACTIVATE MSDIALOG oDlgClasse CENTERED 

Return(.T.)

// ##################################
// Função que armazena a classe MP ##
// ##################################
Static Function ConfirmaMP()

   Local nContar := 0
   
   If Empty(Alltrim(cClasse))
      MsgAlert("Classe MP não selecionada. Verifique!")
      Return(.T.)
   Endif
   
   For nContar = 1 to Len(aMPClasse)
       If aMPClasse[nContar,01] == Alltrim(U_P_CORTA(cCombobx100, "-", 1))
          aMPClasse[nContar,02] := cClasse
          Exit
       Endif
   Next nContar

Return(.T.)

// ####################################################
// Função que pesquisa a calsse do papel selecionado ##
// ####################################################
Static Function AlteraClass

   Local nContar := 0
                                          
   cClasse := Space(02)
   
   For nContar = 1 to Len(aMPClasse)
       If aMPClasse[nContar,01] == Alltrim(U_P_CORTA(cCombobx100, "-", 1))
          cClasse := aMPClasse[nContar,02]
          Exit
       Endif
   Next nContar
                                                          
   If Empty(Alltrim(cClasse))
      cClasse := Space(02)
   Endif   

   oGet1:Refresh()
   
Return(.T.)

// ######################################################################
// Função que verifica se todos os papeis possuem Classe MP associadas ##
// ######################################################################
Static Function FechaMP()

   Local nContar   := 0
   Local lEmBranco := .F.
                                          
   For nContar = 1 to Len(aMPClasse)
       If Empty(Alltrim(aMPClasse[nContar,02]))
          lEmBranco := .T.
          Exit
       Endif   
   Next nContar

   If lEmBranco == .T.
      MsgAlert("Atenção! Existem papeis sem a seleção da Classe MP. Verifique!")
      Return(.T.)
   Endif
    
   lVoltaClasse := .F. 
   
   oDlgClasse:End()   
  
Return(.T.)      


/*



   // ########################################################################
   // Inclui os produtos conforme codificação lida dos códigos dos produtos ##
   // ########################################################################
   For nContar = 1 to Len(aProdutos)

       // #######################################
       // Verifica se o produto lido já existe ##
       // #######################################
       If Select("T_JAEXISTE") > 0
          T_JAEXISTE->( dbCloseArea() )
       EndIf

       cSql := ""       
       cSql := "SELECT B1_COD "
       cSql += "  FROM " + RetSqlName("SB1")
       cSql += " WHERE B1_COD     = '" + Alltrim(aProdutos[nContar]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

       If !T_JAEXISTE->( EOF() )
          Loop
       Endif

       // ##################################
       // Separa os códigos para pesquisa ##
       // ##################################
       kBase    := Substr(aProdutos[nContar],01,02)
       kFaca    := Substr(aProdutos[nContar],03,04)
       kPapel   := Substr(aProdutos[nContar],07,03)
       kTubete  := Substr(aProdutos[nContar],10,01)
       kSerilha := Substr(aProdutos[nContar],11,02)
       kCaracte := Substr(aProdutos[nContar],13,05)
       
       // ##########################
       // Pesquisa o nome da base ##
       // ##########################
       If Select("T_BASE") > 0
          T_BASE->( dbCloseArea() )
       EndIf

       cSql := ""       
       cSql := "SELECT BR_DESCPRD "
       cSql += "  FROM " + RetSqlName("SBR")
       cSql += " WHERE BR_BASE    = '" + Alltrim(kBase) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )
 
       _NomeBase := IIF(T_BASE->( EOF() ), "", T_BASE->BR_DESCPRD)
       
       // ##########################
       // Pesquisa o nome da faca ##
       // ##########################
       If Select("T_FACA") > 0
          T_FACA->( dbCloseArea() )
       EndIf

       cSql := ""       
       cSql := "SELECT BS_DESCPRD "
       cSql += "  FROM " + RetSqlName("SBS") 
       cSql += " WHERE BS_BASE    = '" + Alltrim(kBase) + "'"
       cSql += "   AND BS_CODIGO  = '" + Alltrim(kFaca) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FACA", .T., .T. )
 
       _NomeFaca := IIF(T_FACA->( EOF() ), "", T_FACA->BS_DESCPRD)

       // ###########################
       // Pesquisa o nome do papel ##
       // ###########################
       If Select("T_PAPEL") > 0
          T_PAPEL->( dbCloseArea() )
       EndIf

       cSql := "SELECT BX_DESCPR "
       cSql += "  FROM " + RetSqlName("SBX")
       cSql += " WHERE BX_CONJUN  = 'PAP'"
       cSql += "   AND BX_CODOP   = '" + Alltrim(kPapel) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PAPEL", .T., .T. )
 
       _NomePapel := IIF(T_PAPEL->( EOF() ), "", T_PAPEL->BX_DESCPR)

       // ############################
       // Pesquisa o nome do tubete ##
       // ############################
       If Select("T_TUBETE") > 0
          T_TUBETE->( dbCloseArea() )
       EndIf

       cSql := "SELECT BX_DESCPR "
       cSql += "  FROM " + RetSqlName("SBX")
       cSql += " WHERE BX_CONJUN  = 'TUB'"
       cSql += "   AND BX_CODOP   = '" + Alltrim(kTubete) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TUBETE", .T., .T. )
 
       _NomeTubete := IIF(T_TUBETE->( EOF() ), "", T_TUBETE->BX_DESCPR)

       // #############################
       // Pesquisa o nome do serilha ##
       // #############################
       If Select("T_SERILHA") > 0
          T_SERILHA->( dbCloseArea() )
       EndIf

       cSql := "SELECT BX_DESCPR "
       cSql += "  FROM " + RetSqlName("SBX")
       cSql += " WHERE BX_CONJUN  = 'SER'"
       cSql += "   AND BX_CODOP   = '" + Alltrim(kSerilha) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERILHA", .T., .T. )
 
       _NomeSerilha := IIF(T_SERILHA->( EOF() ), "", T_SERILHA->BX_DESCPR)

       // ####################################
       // Pesquisa o nome do caracteristica ##
       // ####################################
       If Select("T_CARACTE") > 0
          T_CARACTE->( dbCloseArea() )
       EndIf

       cSql := "SELECT BX_DESCPR "
       cSql += "  FROM " + RetSqlName("SBX")
       cSql += " WHERE BX_CONJUN  = 'CAR'"
       cSql += "   AND BX_CODOP   = '" + Alltrim(kCaracte) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

   	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARACTE", .T., .T. )
 
       _NomeCaracte := IIF(T_CARACTE->( EOF() ), "", T_CARACTE->BX_DESCPR)

       _Descricao := Alltrim(_NomeBase)   + " " + Alltrim(_NomeFaca)    + " " + Alltrim(_NomePapel)
       _Auxiliar  := Alltrim(_NomeTubete) + " " + Alltrim(_NomeSerilha) + " " + Alltrim(_NomeCaracte)

//       // ####################################################### 
//       // Carrega array para inclusão do produto na tabela SB1 ##
//       // #######################################################
//       aDados := {} 
//     
//       aAdd( aDados, {"B1_COD"    , aProdutos[nContar], Nil })
//       aAdd( aDados, {"B1_CODBAR" , aProdutos[nContar], Nil })
//       aAdd( aDados, {"B1_DAUX"   , _Auxiliar         , Nil })
//       aAdd( aDados, {"B1_DESC"   , _Descricao        , Nil })
//       aAdd( aDados, {"B1_GRTRIB" , "017"             , Nil })
//       aAdd( aDados, {"B1_GRUPO"  , "0201"            , Nil })
//       aAdd( aDados, {"B1_LOCPAD" , "01"              , Nil })
//       aAdd( aDados, {"B1_LOJPROC", "004"             , Nil })
//       aAdd( aDados, {"B1_MPCLAS" , "06"              , Nil })
//       aAdd( aDados, {"B1_OPERPAD", "01"              , Nil })
//       aAdd( aDados, {"B1_ORIGEM" , "0"               , Nil })
//       aAdd( aDados, {"B1_POSIPI" , "48219000"        , Nil })
//       aAdd( aDados, {"B1_PROC"   , "000329"          , Nil })
//       aAdd( aDados, {"B1_QB"     , 1                 , Nil })
//       aAdd( aDados, {"B1_TIPO"   , "PA"              , Nil })
//       aAdd( aDados, {"B1_UM"     , "RL"              , Nil })
//     
//       MSExecAuto({|x,y| Mata010(x,y)},aDados,3) 
//
//       If lMsErroAuto 
//          MostraErro() 
//       EndIf 

       dbSelectArea("SB1")
       RecLock("SB1",.T.)
       SB1->B1_COD     := aProdutos[nContar]
       SB1->B1_CODBAR  := aProdutos[nContar]
       SB1->B1_DAUX    := _Auxiliar         
       SB1->B1_DESC    := _Descricao        
       SB1->B1_GRTRIB  := "017"             
       SB1->B1_GRUPO   := "0201"            
       SB1->B1_LOCPAD  := "01"              
       SB1->B1_LOJPROC := "004"             
       SB1->B1_MPCLAS  := "06"              
       SB1->B1_OPERPAD := "01"              
       SB1->B1_ORIGEM  := "0"               
       SB1->B1_POSIPI  := "48219000"        
       SB1->B1_PROC    := "000329"          
       SB1->B1_QB      := 1                 
       SB1->B1_TIPO    := "PA"              
       SB1->B1_UM      := "RL"              
       SB1->B1_GARANT  := "2"
       SB1->B1_ZVIR    := "S"
       SB1->B1_LOCALIZ := "N"
       
       If kTubete == "2"
          SB1->B1_PESC    := 0.546
          SB1->B1_ALTU    := 10
          SB1->B1_LARG    := 8
          SB1->B1_COMP    := 8
       Endif
       
       If kTubete == "4"
          SB1->B1_PESC    := 1.400
          SB1->B1_ALTU    := 10
          SB1->B1_LARG    := 14
          SB1->B1_COMP    := 14
       Endif          

       MsUnLock()

   Next nContar

   MsgAlert("Inclusão de produtos realizada com sucesso.")

*/

Return(.T.)