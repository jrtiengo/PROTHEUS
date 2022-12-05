#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM688.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 11/05/2018                                                              ##
// Objetivo..: Programa que permite endereçar nº de série diversos para um produto     ##
// Parâmetros: Sem parâmetros                                                          ##
// ######################################################################################

User Function AUTOM688()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresa  := U_AUTOM539(1, "")      
   Private aFilial   := U_AUTOM539(2, cEmpAnt) 
   Private aStatus   := {"A - A Endereçar", "E - Endereçados", "T - Todos"}
   Private cProduto  := Space(030)
   Private cNomePro  := Space(100)

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private oGet1
   Private oGet2

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

   Private aConsulta := {}

   Private oDlg

   CargaAconsulta(0)

   DEFINE MSDIALOG oDlg TITLE "Endereçamento de Produtos" FROM C(178),C(181) TO C(615),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Empresa" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(062) Say "Filiais" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(131) Say "Produto" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(289) Say "Status"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aEmpresa Size C(055),C(010) PIXEL OF oDlg When lChumba
   @ C(046),C(062) ComboBox cComboBx2 Items aFilial  Size C(066),C(010) PIXEL OF oDlg
   @ C(046),C(131) MsGet    oGet1     Var   cProduto Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID(cNomePro := Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC" ) )
   @ C(046),C(164) MsGet    oGet2     Var   cNomePro Size C(121),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(289) ComboBox cComboBx3 Items aStatus  Size C(058),C(010) PIXEL OF oDlg

   @ C(043),C(351) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlg ACTION( CargaAconsulta(1) )
   @ C(204),C(046) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlg
   @ C(204),C(005) Button "Endereçar"  Size C(037),C(012) PIXEL OF oDlg
   @ C(204),C(350) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################
   // Desenha o Browse ##
   // ###################
   oConsulta := TCBrowse():New( 075 , 005, 495, 180,,{'LG'                ,;
                                                      'Filial'            ,;
                                                      'Produto'           ,;
                                                      'Descrição Produtos',;
                                                      'Armazém'           ,;
                                                      'Documento'         ,;
                                                      'Série'             ,;
                                                      'Origem'            ,;
                                                      'Saldo' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oConsulta:SetArray(aConsulta) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oConsulta:bLine := {||{ If(Alltrim(aConsulta[oConsulta:nAt,01]) == "1", oBranco  ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "2", oVerde   ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "3", oPink    ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "4", oAmarelo ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "7", oPreto   ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "8", oVermelho,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;
                           aConsulta[oConsulta:nAt,06],;
                           aConsulta[oConsulta:nAt,07],;
                           aConsulta[oConsulta:nAt,08],;
                           aConsulta[oConsulta:nAt,09]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##########################################################
// Função que popula o array aConsulta conforme parâmetros ##
// ##########################################################
Static Function CargaAconsulta(kTipo)

   MsgRun("Aguarde! Pesquisando produtos a endereçar ...", "Endereçamento de Produtos",{|| xCargaAconsulta(kTipo) })

Return(.T.)

// ##########################################################
// Função que popula o array aConsulta conforme parâmetros ##
// ##########################################################
Static Function xCargaAconsulta(kTipo)

   Local cSql := ""

   aConsulta := {}

   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql += ""
   cSql := "SELECT SDA.DA_FILIAL ,"
   cSql += "       SDA.DA_PRODUTO," 
   cSql += "	   SDA.DA_LOCAL  ,"
   cSql += "	   SDA.DA_DOC    ,"
   cSql += "	   SDA.DA_SERIE  ,"
   cSql += "	   SDA.DA_ORIGEM ,"
   cSql += "	   SUM(SDA.DA_SALDO) AS SALDO"
   cSql += "  FROM " + RetSqlName("SDA") + " SDA "
   cSql += " WHERE SDA.D_E_L_E_T_ = ''
   
   If kTipo == 0
      cSql += " AND SDA.DA_FILIAL = '" + Alltrim(cFilAnt) + "'"
      cSql += " AND SDA.DA_SALDO <> 0"
   Else
   
      cSql += " AND SDA.DA_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      
      If Empty(Alltrim(cProduto))
      Else
         cSql += " AND SDA.DA_PRODUTO = '" + Alltrim(cProduto) + "'"
      Endif

      Do Case
         Case Substr(cComboBx3,01,01) == "E"
              cSql += " AND SDA.DA_SALDO = 0"
         Case Substr(cComboBx3,01,01) == "A"
              cSql += " AND SDA.DA_SALDO <> 0"
      EndCase
      
   Endif

   cSql += " GROUP BY SDA.DA_FILIAL, SDA.DA_PRODUTO, SDA.DA_LOCAL, SDA.DA_DOC,   SDA.DA_SERIE  ,SDA.DA_ORIGEM"
   cSql += " ORDER BY SDA.DA_FILIAL, SDA.DA_PRODUTO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   T_ENDERECO->( DbGoTop() )
   
   WHILE !T_ENDERECO->( EOF() )
   
      kLegenda := IIF(T_ENDERECO->SALDO == 0, "8", "2")
      kNomePro := Posicione( "SB1", 1, xFilial("SB1") + T_ENDERECO->DA_PRODUTO, "B1_DESC" ) + " " + ;
                  Posicione( "SB1", 1, xFilial("SB1") + T_ENDERECO->DA_PRODUTO, "B1_DAUX" )

      If kTipo == 0
         yEmpresa := cEmpAnt
         yFilial  := cFilAnt
      Else
         yEmpresa := Substr(cComboBx1,01,02)
         yFilial  := Substr(cComboBx2,01,02)
      Endif      

      Do Case
         Case yEmpresa == "01"
              Do Case
                 Case T_ENDERECO->DA_FILIAL == "01"
                      kFilial := "01 - Automatech"
                 Case T_ENDERECO->DA_FILIAL == "02"
                      kFilial := "02 - Caxias do Sul"
                 Case T_ENDERECO->DA_FILIAL == "03"
                      kFilial := "03 - Suprimentos (Antiga)"
                 Case T_ENDERECO->DA_FILIAL == "04"
                      kFilial := "04 - Pelotas (Antiga)"
                 Case T_ENDERECO->DA_FILIAL == "05"
                      kFilial := "05 - São Paulo"
                 Case T_ENDERECO->DA_FILIAL == "06"
                      kFilial := "06 - Espirito Santo"
                 Case T_ENDERECO->DA_FILIAL == "07"
                      kFilial := "07 - Suprimentos (Nova)"
              EndCase        

         Case yEmpresa == "02"
              kFilial := "01 - TI Automação"

         Case yEmpresa == "03"
              kFilial := "01 - Atech"
                      
         Case yEmpresa == "04"
              kFilial := "01 - AtechPel"
              
      EndCase              

      aAdd( aconsulta, { kLegenda              ,;
                         kFilial               ,;
                         T_ENDERECO->DA_PRODUTO,;
                         kNomePro              ,;
                         T_ENDERECO->DA_LOCAL  ,;
                         T_ENDERECO->DA_DOC    ,;
                         T_ENDERECO->DA_SERIE  ,;
                         T_ENDERECO->DA_ORIGEM ,;
                         T_ENDERECO->SALDO     })
               
      T_ENDERECO->( DbSkip() )
      
   ENDDO
   
   If len(aConsulta) == 0
      aAdd( aConsulta, { "", "", "", "", "", "", "", "", 0 } )
   Endif
   
   If kTipo == 0
      Return(.T.)
   Endif
   
   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oConsulta:SetArray(aConsulta) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oConsulta:bLine := {||{ If(Alltrim(aConsulta[oConsulta:nAt,01]) == "1", oBranco  ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "2", oVerde   ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "3", oPink    ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "4", oAmarelo ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "7", oPreto   ,;                         
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "8", oVermelho,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aConsulta[oConsulta:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;
                           aConsulta[oConsulta:nAt,06],;
                           aConsulta[oConsulta:nAt,07],;
                           aConsulta[oConsulta:nAt,08],;
                           aConsulta[oConsulta:nAt,09]}}
      
Return(.T.)

Static Function xxMandaMail(a_Filial, a_Pedido, a_Cliente, a_Email, aSelecao)

   Local lChumba := .F.

   Local cMemo1	  := ""
   Local nContar  := 0
   Local nPosicao := 0

   Local oMemo1
       
   Private nQtdOrig   := 0
   Private nQtdEnde   := 0
   Private nQtdSaldo  := 0
   Private cNumSerie  := Space(20)
   Private xx_VoltaNS := Space(20)
   Private nDBSERIE   := 0
   Private xx_SerieP  := n

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgSer

   Private aBrowse := {}

   nContar    := 0
   nPosicao   := 0
   nQtdOrig   := SDA->DA_QTDORI
   nQtdEnde   := 0
   nQtdSaldo  := 0
   cNumSerie  := Space(20)
   xx_VoltaNS := Space(20)
   nDBSERIE   := 0
   xx_SerieP  := n

   // ##################################################
   // Pesquisa quantos registros já foram endereçados ##
   // ##################################################
   nDBSERIE  := ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )

   nQtdEnde := 0   

   For nContar := 1 to Len(aCols)
       If Empty(Alltrim(aCols[nContar,nDBSERIE]))
       Else
          nQtdEnde := nQtdEnde + 1
       Endif
   Next nContar        

   nQtdSaldo := nQtdOrig - nQtdEnde

   // ################################################
   // Carrega o array aBrowse com os dados da aCols ##
   // ################################################
   For nContar := 1 to Len(aCols)
       aAdd(aBrowse, { aCols[nContar,05] } )
   next nContar    

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "" } )
   Endif   

   DEFINE MSDIALOG oDlgSer TITLE "Endereçamento de Nº de Séries" FROM C(177),C(180) TO C(574),C(443) PIXEL

   oDlgSer:lEscClose := .F.

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL OF oDlgSer

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(125),C(001) PIXEL OF oDlgSer

   @ C(031),C(005) Say "Qtd Original"   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgSer
   @ C(031),C(047) Say "Qtd Endereçada" Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgSer
   @ C(031),C(096) Say "Saldo"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSer
   @ C(176),C(006) Say "Nº de Série"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgSer
   
   @ C(041),C(005) MsGet oGet1 Var nQtdOrig  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSer When lChumba
   @ C(041),C(047) MsGet oGet2 Var nQtdEnde  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSer When lChumba
   @ C(041),C(097) MsGet oGet3 Var nQtdSaldo Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSer When lChumba

   @ C(184),C(005) MsGet oGet4 Var cNumSerie Size C(123),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSer VALID( VERNUMSERIE() )

   // ###################
   // Desenha o Browse ##
   // ###################
   oBrowse := TCBrowse():New( 069 , 005, 160, 154,,{'Nº de Séries' },{20,50,50,50},oDlgSer,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:bLDblClick := {|| xCarregaNS() } 
   
   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }

   ACTIVATE MSDIALOG oDlgSer CENTERED 

   // #############################################################
   // Captura a posição do número de série dentro do array aCols ##
   // #############################################################
   nDBSERIE := ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )      

   // ####################################################################################################
   // Limpa os números de séries do array aCols para receber os novos números de éries do array aBrowse ##
   // ####################################################################################################
   For nContar := 1 to Len(aCols)
       aCols[nContar,nDbSerie] := Space(20)
   Next nContar    

   // #############################################################################
   // Atualiza o array aCols com os números de séries digitados no array aBrowse ##
   // #############################################################################
   For nContar := 1 to Len(aBrowse)
   
       If nContar == xx_SerieP
          xx_VoltaNS := aBrowse[nContar,01]
       Endif   

       // ##########################################################################
       // Pesquisa o próximo número de série disponível para receber a informação ##
       // ##########################################################################
       For nPosicao := 1 to Len(aCols)
           If Empty(Alltrim(aCols[nPosicao,nDbSerie]))
              Exit
           Endif
       Next nPosicao
       
       aCols[nPosicao,nDbSerie] := aBrowse[nContar,01]
       
   Next nContar    

   SDA->DA_SALDO := SDA->DA_QTDORI - Len(aBrowse)

Return(xx_VoltaNS)

// ######################################################
// Função que carrega o número de série a ser alterado ##
// ######################################################
Static Function xCarregaNS()

   nQtdEnde := nQtdEnde - 1
   nQtdSaldo := nQtdOrig - nQtdEnde

   cNumSerie := aBrowse[oBrowse:nAt,01]
   aBrowse[oBrowse:nAt,01] := ""

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

   oGet4:SetFocus()

Return(.T.)

// ########################################################
// Função que verifica o número de série digitado/bipado ##
// ########################################################
Static Function VerNumSerie()

   Local nContar   := 0
   Local nExiste   := 0
   Local kSerie    := cNumSerie
   Local lTemSerie := .F.
   Local lEbranco  := .F.
   
   If Empty(Alltrim(cNumSerie))
      Return(.T.)
   Endif

   // ################################################################################
   // Verifica se o array aBrowse está totalmente em branco. Se tiver, inicializa-o ##
   // ################################################################################
   lTemSerie := .F.
   
   For nContar = 1 to Len(aBrowse)
       If Empty(Alltrim(aBrowse[nContar,01]))
       Else
          lTemSerie := .T.
          Exit
       Endif
   Next nContar       

   If lTemSerie == .F.
      aBrowse := {}
   Endif

   // ################################################
   // Verifica se o endereçamento já foi finalizado ##
   // ################################################
   If nQtdSaldo == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não existe mais saldo disponível para endereçar." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique!")
      oGet4:SetFocus()
      Return(.T.)
   Endif   

   // #############################################################
   // Captura a posição do número de série dentro do array aCols ##
   // #############################################################
   nDBSERIE := ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )      
   
   // ##########################################################
   // Verifica se o número de série digitado já foi informado ##
   // ##########################################################
   nExiste := 1
   For nContar = 1 to Len(aBrowse)
       If Upper(Alltrim(aBrowse[nContar,1])) == Upper(Alltrim(kSerie))
          nExiste := nExiste + 1
       Endif
   Next nContar
   
   If nExiste > 1
      MsgAlert("Atenção! Número de série já foi informado. Verifique!")
      cNumSerie := Space(20)
      oGet4:SetFocus()
      Return(.T.)
   Endif

   // ######################################
   // Inclui o número de série no aBrowse ##
   // ######################################
  lEbranco := .F.
   For nContar = 1 to Len(aBrowse)
       If Empty(Alltrim(aBrowse[nContar,01]))
          lEbranco := .T.
          Exit
       Endif
   Next nContar          

   If lEBranco == .T.
      aBrowse[nContar,01] := kSerie
   Else   
      aAdd( aBrowse, { kSerie } )
   Endif

   cNumSerie := Space(20) 
   
   oBrowse:SetArray(aBrowse) 
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01]} }    
   oBrowse:Refresh()

   // ####################################
   // Atualiza o saldo do endereçamento ##
   // ####################################
   nQtdEnde  := Len(aBrowse)
   nQtdSaldo := nQtdOrig - nQtdEnde
   
   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

   oGet4:SetFocus()

Return(.T.)