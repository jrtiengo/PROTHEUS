#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define DS_MODALFRAME   128   // Sem o 'x' para cancelar

// #########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                  ##
// -------------------------------------------------------------------------------------- ##
// Referencia: PE_MATA265.PRW                                                             ##
// Parâmetros: Nenhum                                                                     ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                            ##
// -------------------------------------------------------------------------------------- ##
// Autor.....: Cesar Mussi                                                                ##
// Data......: 09/05/2011                                                                 ##
// Objetivo..: Função que verifica os endereçamentos antes da gravação                    ##
// #########################################################################################
User Function A265COL()

   Local nContar     := 0
   Local nDBLOCALIZ
   Local nDBQUANT
   Local nDBDATA
   Local _cLocal     := GetMv("JPC265LOC")
   Local a_AreaAnter := SB1->( GetArea() )

   nContar    := 0
   nDBITEM 	  := ascan(aHeader,{ |x| x[2] == 'DB_ITEM   ' } )
   nDBLOCALIZ := ascan(aHeader,{ |x| x[2] == 'DB_LOCALIZ' } )
   nDBQUANT	  := ascan(aHeader,{ |x| x[2] == 'DB_QUANT  ' } )
   nDBDATA    := ascan(aHeader,{ |x| x[2] == 'DB_DATA   ' } )

   SB1->( dbsetorder( 1 ) )                        // B1_FILIAL + B1_COD
   SB1->( dbseek( xFilial('SDA')+M->DA_PRODUTO ) ) // Localiza o Material

   aColsBase := aClone(aCols[1])

   aCols[1][nDBLOCALIZ] 	:= _cLocal      // Pega a localiz.padrao do Cadastro
   aCols[1][nDBQUANT] 		:= 1            // Pega o Saldo a Distribuir
   aCols[1][nDBDATA] 		:= dDataBase    // Pega a Data de hoje

   For _nPos := 2 to SDA->DA_SALDO
       axCols := aClone(aColsbase)
       axCols[nDBITEM] 		:= StrZero(_nPos,Len(axCOLS[nDBITEM]))
       axCols[nDBLOCALIZ] 	:= _cLocal      // Pega a localiz.padrao do Cadastro
       axCols[nDBQUANT] 	:= 1            // Pega o Saldo a Distribuir
       axCols[nDBDATA] 		:= dDataBase    // Pega a Data de hoje

       aAdd(aCols,axCols)
   Next _nPos

   RestArea( a_AreaAnter )

Return(.t.)

// ##################################################################
// Função que verifica a quantidade de números de séries digitados ##
// ##################################################################
USER FUNCTION MA265TDOK

   Local lret        := .t.
   Local nContar     := 0
   Local nPreenchido := 0
   Local nContar     := 0 

//   // #####################################################################################
//   // Conta quantos números de séries foram informados e verifica pelo saldo a endereçar ##
//   // #####################################################################################
//   nDBSERIE := ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )
//
//   For nContar = 1 to Len(aCols)
//       If Empty(Alltrim(aCols[nContar,nDBSERIE]))
//       Else
//          nPreenchido := nPreenchido + 1
//       Endif
//   Next nContar
//   
//   If nPreenchido <> SDA->DA_QTDORI
//      MsgAlert("Atenção!"                                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
//               "Ainda existem registros sem a informação do nº de Série." + chr(13) + chr(10) + chr(13) + chr(10) + ;
//               "Verifique!")
//      lRet := .F.
//   Else
//      lRet := .T.                        
//   Endif



   nDBSERIE 	:= ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )

   For _n := 1 to Len(aCols)
       IF LOCALIZA(M->DA_PRODUTO)
  
          // #####################################################
          // Valida se a linha tem o numero de serie cadastrado ##
          // #####################################################
          IF EMPTY(aCols[_n,nDBSerie])
             lret := .f.
             ALERT("Verifique Numero de Serie !")
             Exit
          ENDIF
       ENDIF
   next _n

Return(lRet)

// #################################################################
// Função que abre a tela para digitar ou bipar o número de série ##
// #################################################################
User Function JPCNSERIE

   Local _nDBSERIE 	:= ascan(aHeader,{ |x| x[2] == 'DB_NUMSERI' } )
   Local _nPos 		:= oGetd:oBrowse:nAt
   Local _cVarSer   := Space(len(aCols[n,_nDBSERIE]))
   Local _nLen 		:= 0
   Local _nSerie 	:= aCols[n,_nDBSERIE]

   If _nPos < Len(aCols)

      _nPos++
	  
	  For _nLen := _nPos to len(aCols)

		  DEFINE MSDIALOG oDlg1 TITLE "Informe os No. Series" FROM 33,25 TO 110,349 PIXEL  

		  @ 01,05 TO 032, 128 OF oDlg1 PIXEL
		  @ 08,08 SAY "No. Sereie" SIZE 55, 7  OF oDlg1 PIXEL  
		  @ 18,08 MSGET _nSerie    SIZE 37, 11 OF oDlg1 PIXEL Picture "@!" VALID IIf(!empty(_nSerie), eval({|| aCols[_nLen,_nDBSERIE]:=_nSerie,.t.}),eval({|| aCols[_nLen,_nDBSERIE]:=_cVarSer,.f.}))
			
		  DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End()) ENABLE OF oDlg1
		  DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End()) ENABLE OF oDlg1

		  ACTIVATE MSDIALOG oDlg1 CENTERED
		
		  oGetd:oBrowse:Refresh()

		  If nOpca == 0
			 exit
		  Endif
	  
	  Next

   Endif


//   Local cGet1	 := Space(25)
//   Local cGet2	 := Space(25)
//   Local oGet1
//   Local oGet2
//
//   Private oDlg				// Dialog Principal
//
//   If _nPos < Len(aCols)
//      _nPos++
//
//      DEFINE MSDIALOG oDlg TITLE "Endereçamento" FROM C(178),C(181) TO C(283),C(339) PIXEL
// 
//   	  @ C(004),C(004) Say "Informe o Nº de Série " Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//	  @ C(027),C(005) Say "Nº de Série Anterior"   Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
//
//	  @ C(013),C(005) MsGet oGet1 Var cGet1 Size C(069),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
//	  @ C(037),C(005) MsGet oGet2 Var cGet2 Size C(069),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
//
//      ACTIVATE MSDIALOG oDlg CENTERED 
//      
//




   // ########################################################################### 
   // Verifica se o aCol possui registros. Se não tiver retorna sem fazer nada ##
   // ###########################################################################
   If Len(aCols) == 0
      Return("")
   Endif   

Return _nSerie

// #################################################################
// Função que abre a tela para digitar ou bipar o número de série ##
// #################################################################
User Function JPCNSEQUENCIAL()

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

   nQtdEnde  := 0  
   nQtdSaldo := 0 

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

   // #####################################
   // Atualiza o saldo da tela principal ##
   // #####################################
   nQtdEnde  := 0  

   For nContar := 1 to Len(aCols)
       If Empty(Alltrim(aCols[nContar,nDBSERIE]))
       Else
          nQtdEnde := nQtdEnde + 1
       Endif
   Next nContar        

   nQtdSaldo := nQtdOrig - nQtdEnde

// SDA->DA_SALDO := SDA->DA_QTDORI - nQtdEnde

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
   nQtdEnde  := 0
   nQtdSaldo := 0

   For nContar := 1 to Len(aBrowse)
       If Empty(Alltrim(aBrowse[nContar,01]))
       Else
          nQtdEnde := nQtdEnde + 1
       Endif
   Next nContar        

   nQtdSaldo := nQtdOrig - nQtdEnde
   
   // #######################################################
   // Atualiza os dados da tela e endereçamento sequencial ##
   // #######################################################
   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

   oGet4:SetFocus()

Return(.T.)