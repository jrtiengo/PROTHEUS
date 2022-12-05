#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTA011.PRW                                                             ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 22/05/2017                                                              ##
// Objetivo..: Painel Compras                                                          ##
// ######################################################################################

User Function AUTA011

   Local cMemo1	 := ""
   Local oMemo1

   Private aFilial  := U_AUTOM539(2, cEmpAnt)
   Private aStatus  := {}
   Private _nDAnt   := GetMv("MV_DANTSTS")
   Private dInicial := Date() - _nDAnt
   Private dFinal   := Ctod("31/12/" + Strzero(Year(Date()),4))

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private oGet1
   Private oGet2
      
   Private aConsulta := {}
   
   Private oDlgPC

   U_AUTOM628("AUTA011")

   // ###############################
   // Inicializa os combos da tela ##
   // ###############################
   cComboBx1 := aFilial[1]

   // #############################
   // Carrega o combo dos status ##
   // #############################
   aAdd( aStatus, "01-Aguardando Liberação" )
   aAdd( aStatus, "02-Aguardando Liberação Margem" )
   aAdd( aStatus, "03-Aguardando Liberação de Credito" )
   aAdd( aStatus, "04-Aguardando Liberação de Estoque" )
   aAdd( aStatus, "05-Aguardando data de entrega" )
   aAdd( aStatus, "06-Em compra" )
   aAdd( aStatus, "07-Em produção" )
   aAdd( aStatus, "08-Aguardando separação estoque" )
   aAdd( aStatus, "09-Aguardando cliente" )
   aAdd( aStatus, "10-Aguardando faturamento" )
   aAdd( aStatus, "11-Item faturado" )
   aAdd( aStatus, "12-Item expedido" )
   aAdd( aStatus, "13-Aguardando distribuidor" )
   aAdd( aStatus, "14-Pedido cancelado" )
   aAdd( aStatus, "15-Pedido Com Análise de Crédito Rejeitado" )

   cComboBx2 := "04-Aguardando Liberação de Estoque"

   // ############################################## 
   // Executa a Query para popular o Grid da Tela ##
   // ##############################################
   RodaSql(0)

   DEFINE MSDIALOG oDlgPC TITLE "Painel Compras" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgPC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlgPC

   @ C(036),C(005) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(036),C(082) Say "Status"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(036),C(236) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(036),C(279) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC

   @ C(045),C(005) ComboBox cComboBx1 Items aFilial  Size C(072),C(010)                              PIXEL OF oDlgPC
   @ C(045),C(082) ComboBox cComboBx2 Items aStatus  Size C(150),C(010)                              PIXEL OF oDlgPC
   @ C(045),C(236) MsGet    oGet1     Var   dInicial Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC
   @ C(045),C(279) MsGet    oGet2     Var   dFinal   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC
   @ C(042),C(320) Button "Pesquisar"                Size C(048),C(012)                              PIXEL OF oDlgPC ACTION( RodaSql(1) )

   @ C(210),C(005) Button "Cad.Produtos"          Size C(037),C(012) PIXEL OF oDlgPC ACTION( MATA010() )
   @ C(210),C(043) Button "Saldo"                 Size C(037),C(012) PIXEL OF oDlgPC ACTION( kSaldoProd(aConsulta[oConsulta:nAt,10]) )
   @ C(210),C(100) Button "Ped. Compra"           Size C(037),C(012) PIXEL OF oDlgPC ACTION( MATA121() )
   @ C(210),C(138) Button "Alt.Data/PC"           Size C(037),C(012) PIXEL OF oDlgPC ACTION( U_AUTOM549() )
   @ C(210),C(177) Button "Ped.Venda"             Size C(037),C(012) PIXEL OF oDlgPC ACTION( MATA410() )
   @ C(210),C(236) Button "Faturamento/Expedição" Size C(066),C(012) PIXEL OF oDlgPC ACTION( U_AUTOM206() )
   @ C(210),C(316) Button "Kardex"                Size C(037),C(012) PIXEL OF oDlgPC ACTION( AbreKardexP(aConsulta[oConsulta:nAt,10]) )
   @ C(210),C(380) Button "Resíduos"              Size C(037),C(012) PIXEL OF oDlgPC ACTION( U_AUTOM581() )
   @ C(210),C(461) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlgPC ACTION( oDlgPC:End() )

   // #########################
   // Desenha o grid na tela ##
   // #########################
   oConsulta := TCBrowse():New( 075 , 005, 633, 190,, {'Status'      ,;                                                  // 01
                                                     'Filial'      ,;                                                  // 02
                                                     'Log'         ,;                                                  // 03
                                                     'Oportunidade',;                                                  // 04
                                                     'Pedido'      ,;                                                  // 05
                                                     'Item'        ,;                                                  // 06
                                                     'Cód.Cliente' ,;                                                  // 07
                                                     'Loja'        ,;                                                  // 08
                                                     'Cliente'     ,;                                                  // 09
                                                     'Cód.Produto' ,;                                                  // 10
                                                     'Part Number' ,;                                                  // 11
                                                     'Produto'     ,;                                                  // 12
                                                     'Entrega'},{20,50,50,50},oDlgPC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // 13
   
   // ########################### 
   // Seta vetor para a browse ##
   // ###########################                           
   oConsulta:SetArray(aConsulta) 
    
   // ########################################
   // Monta a linha a ser exibina no Browse ##
   // ########################################
   oConsulta:bLine := {||{ aConsulta[oConsulta:nAt,01],;
                           aConsulta[oConsulta:nAt,02],;
                           aConsulta[oConsulta:nAt,03],;
                           aConsulta[oConsulta:nAt,04],;
                           aConsulta[oConsulta:nAt,05],;
                           aConsulta[oConsulta:nAt,06],;
                           aConsulta[oConsulta:nAt,07],;
                           aConsulta[oConsulta:nAt,08],;
                           aConsulta[oConsulta:nAt,09],;
                           aConsulta[oConsulta:nAt,10],;
                           aConsulta[oConsulta:nAt,11],;
                           aConsulta[oConsulta:nAt,12],;
                           aConsulta[oConsulta:nAt,13]}}
   
   oConsulta:bHeaderClick := {|oObj,nCol| oConsulta:aArray := Ordenar(nCol,oConsulta:aArray),oConsulta:Refresh()}

   ACTIVATE MSDIALOG oDlgPC CENTERED 

Return(.T.)

// #######################################################
// Função que ordena o grid conforme coluna selecionada ##
// #######################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)


Return(.T.)



/*
User Function AUTA011

	Local aPVItem   := {'','',''}
	Private _cPerg  := "AUTA011   "
	Private aConsulta := {}
	Private oConsulta
	Private oTimer
	Private cPedAtu := ""
	Private nCor    := 16776960
	Private _nDAnt  := GetMv("MV_DANTSTS")

    Private aFilial := U_AUTOM539(2, cEmpAnt)
    Private cComboBx1
    Private nMeter1	:= 0
    Private oMeter1
	
    // ###########################
	// Tratamento das perguntas ##
	// ###########################
	AjustaSX1( _cPerg )

	DEFINE DIALOG oDlg TITLE "Status dos Pedidos de Venda" FROM 000,000 TO 540,1200 PIXEL

    @ C(001),C(005) Jpeg FILE "nlogoautoma.bmp"      Size C(075),C(051)                 PIXEL NOBORDER OF oDlg
    @ C(009),C(336) Say "Filial"                     Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
    @ C(008),C(350) ComboBox cComboBx1 Items aFilial Size C(120),C(010)                 PIXEL ON CHANGE( RodaSql(.T.) ) OF oDlg 

 	oConsulta := TCBrowse():New( 35, 01, 600, 215,, {'Status','Filial','Log', 'Oportunidade','Pedido','Item','Cód.Cliente','Loja','Cliente','Cód.Produto','Produto','Entrega'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

    // ######################################################
	// Selecionar os registros e atualizar o array da tela ##
	// ######################################################
	RodaSql(.T.)

    // ##########################################
	// Evento de clique no cabeçalho da browse ##
	// ##########################################
	oConsulta:bHeaderClick := {|| Nil } 

    // ##################################
	// Evento de duplo click na celula ##
	// ##################################
	oConsulta:bLDblClick   := {|| aPVItem[ 1 ] := aConsulta[ oConsulta:nAt, 04 ],;
								aPVItem[ 2 ] := aConsulta[ oConsulta:nAt, 05 ],;
								aPVItem[ 3 ] := aConsulta[ oConsulta:nAt, 02 ],;
								MostraLog( aPVItem ) }

	@ C(197),C(005) Button "Faturamento/Expedição" Size C(070),C(012) PIXEL OF oDlg ACTION( U_AUTOM206() )

	DEFINE SBUTTON FROM 254,440 TYPE 13 ACTION ( RodaSql(.T.) ) Of oDlg PIXEL ENABLE
	DEFINE SBUTTON FROM 254,470 TYPE 15 ACTION ( aPVItem[ 1 ] := aConsulta[ oConsulta:nAt, 04 ], aPVItem[ 2 ] := aConsulta[ oConsulta:nAt, 05 ], aPVItem[ 3 ] := aConsulta[ oConsulta:nAt, 02 ], MostraLog( aPVItem ) ) Of oDlg PIXEL ENABLE
	DEFINE SBUTTON FROM 254,500 TYPE 17 ACTION ( RodaSql(.F.)  ) Of oDlg PIXEL ENABLE
	DEFINE SBUTTON FROM 254,530 TYPE  2 ACTION ( oDlg:End() ) Of oDlg PIXEL ENABLE

	DEFINE TIMER oTimer INTERVAL 70000  ACTION ( RodaSql(.T.) )  Of oDlg
	oTimer:Activate()

	ACTIVATE DIALOG oDlg CENTERED
	
Return

*/

// ###################################
// Roda a Query e prepara os campos ##
// ###################################
Static Function RodaSql(kTipo)

   MsgRun("Aguarde! Pesquisando Dados do Painel Compras ...", "Painel Compras",{|| xRodaSql(kTipo) })

Return(.T.)

// ###################################
// Roda a Query e prepara os campos ##
// ###################################
Static Function xRodaSql(kTipo)

   Local cSql      := ""
   Local aStru     := {}
   Local _cOport   := Space(6)
   Local _cData    := Space(10)
   Local _cHora    := Space(5)
   Local _lLimReg  := .F. // Quando os parâmetros forem todos de branco a zzz, limito por data para não sobrecarregar o array
   Local _lVend    := .F. // Verificar se usuário é cadastrado como vendedor. Se for mostrar apenas os seus pedidos, caso contrário, mostra tudo.
   Local nRegLidos := 0

   _lLimReg := LimReg()
   _aVend   := Vender()
   _lVend   := _aVend[ 1 ]
   _cCodV   := _aVend[ 2 ]
   _cEstilo := _aVend[ 3 ]

   aConsulta := {}

   // ########################################
   // Pesquisa os dadso conforme parâmetros ##
   // ########################################
   If Select("T_SC6") > 0
      T_SC6->( dbCloseArea() )
   EndIf

	cSql := ""
	cSql := "SELECT SC6.C6_STATUS ," + CHR(13)
	cSql += "       SC6.C6_FILIAL ," + CHR(13)
	cSql += "       SC6.C6_NUM    ," + CHR(13)
	cSql += "       SC6.C6_CLI    ," + CHR(13)
	cSql += "       SC6.C6_LOJA   ," + CHR(13)
	cSql += "       SC6.C6_PRODUTO," + CHR(13)
	cSql += "       SC6.C6_ITEM   ," + CHR(13)
	cSql += "       SC6.C6_NUMORC ," + CHR(13)
	cSql += "       SC5.C5_EMISSAO," + CHR(13)
	cSql += "       SC6.C6_PRVCOMP," + CHR(13)
	cSql += "       SC6.C6_ENTREG  " + CHR(13)
    cSql += "   FROM " + RetSqlName("SC6") + " SC6, " + CHR(13)
    cSql += "        " + RetSqlName("SC5") + " SC5  " + CHR(13)
	cSql += "  WHERE SC6.C6_FILIAL = '" + Substr(cComboBx1,01,02) + "'" + CHR(13)
    cSql += "    AND SC6.C6_STATUS = '" + Substr(cComboBx2,01,02) + "'" + CHR(13)
    cSql += "    AND SC5.C5_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
    cSql += "    AND SC5.C5_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)"
	cSql += "    AND SC6.C6_NUM      = SC5.C5_NUM    " + chr(13)
	cSql += "    AND SC6.C6_FILIAL   = SC5.C5_FILIAL " + chr(13)
	cSql += "    AND SC5.D_E_L_E_T_  = ''" + chr(13)
	cSql += "    AND SC6.D_E_L_E_T_  = ''" + chr(13)
	cSql += "  ORDER BY C6_FILIAL, C6_NUM, C6_ITEM " + chr(13)

	cSql := ChangeQuery( cSql )
	MemoWrite( "AUTA011.txt", cSql )

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SC6", .T., .T. )

   If Select("T_SC6") > 0
      If Select("T_ADY") > 0
  	     T_ADY->( dbCloseArea() )
  	  Endif	  
   EndIf

   // ##############################
   // Formatar os campos para uso ##
   // ##############################
   aStru := T_SC6->( dbStruct() )
   aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_SC6->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_SC6", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

   T_SC6->( dbGoTop() )

   // ################################
   // Vetor com elementos do Browse ##
   // ################################
   While !T_SC6->( Eof() )

      If Len(Alltrim(T_SC6->C6_PRODUTO)) > 6
	     T_SC6->( DbSkip() )
	     Loop
	  Endif   

      nRegLidos += 1

      // #######################################
	  // Localizando o número da oportunidade ##
	  // #######################################
	  _cOport := Space(6)
	  If !Empty( AllTrim( T_SC6->C6_NUMORC ) )
	 	 dbSelectArea("SCJ")
		 dbSetOrder(1)
		 If dbSeek( T_SC6->C6_FILIAL + SubStr( T_SC6->C6_NUMORC, 1, 6 ) )
			_cOport := SCJ->CJ_NROPOR
		 EndIf
		 dbSelectArea("T_SC6")
  	  EndIf
		
      // ##########################################
	  // Localizando Data e Hora do Status atual ##
	  // ##########################################
	  If Select("T_LOG") > 0
		 T_LOG->( dbCloseArea() )
	  EndIf

      cSql := ""
	  cSql := "SELECT ZZ0_DATA, "
	  cSql += "       ZZ0_HORA  "
	  cSql += "  FROM " + RetSqlName("ZZ0")
	  cSql += " WHERE ZZ0_PEDIDO = '" + Alltrim(T_SC6->C6_NUM)    + "'"
	  cSql += "   AND ZZ0_ITEMPV = '" + Alltrim(T_SC6->C6_ITEM)   + "'"
	  cSql += "   AND ZZ0_FILIAL = '" + Alltrim(T_SC6->C6_FILIAL) + "'"
	  cSql += "   AND ZZ0_STATUS = '" + Alltrim(T_SC6->C6_STATUS) + "'"
		
	  cSql := ChangeQuery( cSql )
  	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_LOG",.T.,.T.)
		
	  _cData := Space(10)
	  _cHora := Space(5)
		
	  While !T_LOG->( Eof() )
	     _cData := DtoC( StoD( T_LOG->ZZ0_DATA ) )
		 _cHora := T_LOG->ZZ0_HORA
		 T_LOG->( dbSkip() )
   	  Enddo
		
	  T_LOG->( dbCloseArea() )
	  dbSelectArea("T_SC6")
		
      If Empty(AllTrim(T_SC6->C6_PRVCOMP)) 
	     _xData := ""
	  Else   
	     _xData := DtoC( StoD( T_SC6->C6_PRVCOMP ) )
	  Endif
		
      // ######################################################################################################
      // Se pedido estiver com Status 07 - Em Produção, carrega com a data prevista de Entrega para display. ##
      // ######################################################################################################
	  If T_SC6->C6_STATUS == "07"
	     _xData := Substr(T_SC6->C6_ENTREG,07,02) + "/" + Substr(T_SC6->C6_ENTREG,05,02) + "/" + Substr(T_SC6->C6_ENTREG,01,04)
	  Endif

	  _xData := _xData

      // ################################################## 
      // Pesquisa o nome do Status do Pedido Selecionado ##
      // ##################################################
      Do Case
         Case T_SC6->C6_STATUS == "01"
              kStatus := "01-Aguardando Liberação" 
         Case T_SC6->C6_STATUS == "02"
              kStatus := "02-Aguardando Liberação Margem" 
         Case T_SC6->C6_STATUS == "03"
              kStatus := "03-Aguardando Liberação de Credito" 
         Case T_SC6->C6_STATUS == "04"
              kStatus := "04-Aguardando Liberação de Estoque" 
         Case T_SC6->C6_STATUS == "05"
              kStatus := "05-Aguardando data de entrega" 
         Case T_SC6->C6_STATUS == "06"
              kStatus := "06-Em compra" 
         Case T_SC6->C6_STATUS == "07"
              kStatus := "07-Em produção" 
         Case T_SC6->C6_STATUS == "08"
              kStatus := "08-Aguardando separação estoque" 
         Case T_SC6->C6_STATUS == "09"
              kStatus := "09-Aguardando cliente" 
         Case T_SC6->C6_STATUS == "10"
              kStatus := "10-Aguardando faturamento" 
         Case T_SC6->C6_STATUS == "11"
              kStatus := "11-Item faturado" 
         Case T_SC6->C6_STATUS == "12"
              kStatus := "12-Item expedido" 
         Case T_SC6->C6_STATUS == "13"
              kStatus := "13-Aguardando distribuidor" 
         Case T_SC6->C6_STATUS == "14"
              kStatus := "14-Pedido cancelado" 
         Case T_SC6->C6_STATUS == "15"
              kStatus := "15-Pedido Com Análise de Crédito Rejeitado" 
      EndCase 

	  aAdd( aConsulta, { kStatus                                                                         ,;
	 				   T_SC6->C6_FILIAL                                                                ,;
                       _cData + " " + _cHora                                                           ,;
	 				   _cOport                                                                         ,; 
	 				   T_SC6->C6_NUM                                                                   ,; 
	 				   T_SC6->C6_ITEM                                                                  ,; 
	 				   T_SC6->C6_CLI                                                                   ,; 
	 				   T_SC6->C6_LOJA                                                                  ,; 
	 				   Posicione("SA1", 1, xFilial("SA1") + T_SC6->C6_CLI + T_SC6->C6_LOJA, "A1_NOME") ,;
	 				   T_SC6->C6_PRODUTO                                                               ,; 
	 				   Posicione("SB1", 1, xFilial("SB1") + T_SC6->C6_PRODUTO, "B1_PARNUM")            ,; 
	 				   Posicione("SB1", 1, xFilial("SB1") + T_SC6->C6_PRODUTO, "B1_DESC")              ,; 
	 				   _xData                                                                          })

//	  aAdd( aConsulta, { PadR( Iif( T_SC6->C6_STATUS <> '  ', T_SC6->C6_STATUS + "-" + Tabela( "Z0", T_SC6->C6_STATUS ), "SEM STATUS" ), 50 ),;
//	 				   PadR( AllTrim( T_SC6->C6_FILIAL ), 3 ),;
//                       Padr( (_cData + " " + _cHora), 20)    ,;
//	 				   PadR( _cOport, 8 )                    ,; 
//	 				   PadR( T_SC6->C6_NUM, 8 )              ,; 
//	 				   PadR( T_SC6->C6_ITEM, 3 )             ,; 
//	 				   PadR( T_SC6->C6_CLI, 8 )              ,; 
//	 				   PadR( T_SC6->C6_LOJA, 3 )             ,; 
//	 				   PadR( Posicione("SA1", 1, xFilial("SA1") + T_SC6->C6_CLI + T_SC6->C6_LOJA, "A1_NOME"), 50 ),;
//	 				   PadR( T_SC6->C6_PRODUTO, 10 )         ,; 
//	 				   PadR( Posicione("SB1", 1, xFilial("SB1") + T_SC6->C6_PRODUTO, "B1_DESC"), 50 ),; 
//	 				   PadR( _xData, 20 ) } )
//
//// 	 				   PadR( Iif( Empty( AllTrim( _cData ) ), DtoC( StoD( T_SC6->C5_EMISSAO ) ), _cData ) + " " + _cHora, 20 ) } )
//
//                       // (11)	PadR( Iif( Empty( T_SC6->C6_PRVCOMP ), "", DtoC( StoD( T_SC6->C6_PRVCOMP ) ) ), 20 ),;

	  T_SC6->( dbSkip() )
	
   Enddo
       
   T_SC6->( dbCloseArea() )
	
   If Len( aConsulta ) == 0
 	  aAdd( aConsulta, { '','','','','','','','NENHUM REGISTRO ENCONTRADO','','','','','' } )
   EndIf
	
   If kTipo == 0
      Return(.T.)
   Endif
      
   // ###################################   
   // Ordena o Array para Visualização ##
   // ###################################
   ASORT(aConsulta,,,{ | x,y | X[2] + Substr(x[12],01,10) < Y[2] + Substr(y[12],01,10) } )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################
   oConsulta:SetArray( aConsulta )

   // ########################################
   // Monta a linha a ser exibida no Browse ##
   // ########################################
   oConsulta:bLine := {||{ aConsulta[ oConsulta:nAt, 01 ],;
                         aConsulta[ oConsulta:nAt, 02 ],;
                         aConsulta[ oConsulta:nAT, 03 ],;
                         aConsulta[ oConsulta:nAT, 04 ],;
                         aConsulta[ oConsulta:nAT, 05 ],;
                         aConsulta[ oConsulta:nAt, 06 ],;
                         aConsulta[ oConsulta:nAt, 07 ],;
                         aConsulta[ oConsulta:nAT, 08 ],;
                         aConsulta[ oConsulta:nAT, 09 ],;
                         aConsulta[ oConsulta:nAt, 10 ],;
                         aConsulta[ oConsulta:nAt, 11 ],;
                         aConsulta[ oConsulta:nAt, 12 ],;
                         aConsulta[ oConsulta:nAT, 13 ] } }
	
	oConsulta:Refresh()

Return

// ###############################################################################################
// Faz a verificação dos parâmetros, se precisa limitar por data para não sobrecarregar o array ##
// ###############################################################################################
Static Function LimReg()

	Local _lLimReg := .F.
	
    _lLimReg := AllTrim( mv_par01 ) == "" .And. AllTrim( mv_par02 ) > "z";
    .And. AllTrim( mv_par03 ) == "" .And. AllTrim( mv_par04 ) > "z";
    .And. AllTrim( mv_par05 ) == "" .And. AllTrim( mv_par06 ) > "z";
    .And. AllTrim( mv_par07 ) == "" .And. AllTrim( mv_par08 ) > "z";
    .And. AllTrim( mv_par09 ) == "" .And. AllTrim( mv_par10 ) > "z"

Return( _lLimReg )

// ###############################################################
// Tela para exibir a sequencia de logs para o item selecionado ##
// ###############################################################
Static Function MostraLog( aPv )
	
	Local _cTitle := "Log de Status - PV: "+ aPV[ 01 ] +" Item:"+aPV[ 02 ]
	Local cQuery := ""
	Local aStru  := {}
	Local aBrows := {}
	Local oBrows
	
	cQuery := " SELECT * "
	cQuery += " FROM "+ RetSqlName("ZZ0")
	cQuery += " WHERE ZZ0_PEDIDO = '"+ aPV[ 01 ] +"' AND ZZ0_ITEMPV = '"+ aPV[ 02 ] +"' AND ZZ0_FILIAL = '"+ aPV[ 03 ] +"' AND D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZZ0_DATA, ZZ0_HORA "
	
	cQuery := ChangeQuery( cQuery )
	If Select("T_ZZ0") > 0
		T_ZZ0->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_ZZ0",.T.,.T.)
	
	// Formatar os campos para uso
	aStru := T_ZZ0->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_ZZ0->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_ZZ0", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	T_ZZ0->( dbGoTop() )

    // Vetor com elementos do Browse
	While !T_ZZ0->( Eof() )
		aAdd( aBrows, { Padr( Iif( T_ZZ0->ZZ0_STATUS <> '  ', T_ZZ0->ZZ0_STATUS+"-"+ Tabela( "Z0", T_ZZ0->ZZ0_STATUS ), "SEM STATUS" ),60 ),;
						PadR( T_ZZ0->ZZ0_USER+"-"+ Upper( UsrRetName( T_ZZ0->ZZ0_USER ) ), 30 ),;
						PadR( DtoC( StoD( T_ZZ0->ZZ0_DATA ) ), 10 ),;
						PadR( T_ZZ0->ZZ0_HORA, 10 ),;
						Padr( T_ZZ0->ZZ0_ORIGEM, 20 ) } )
		T_ZZ0->( dbSkip() )
	End
       
	T_ZZ0->( dbCloseArea() )

	If Len( aBrows ) > 0

		DEFINE DIALOG oDlg2 TITLE _cTitle FROM 180,180 TO 500,800 PIXEL
		                 
		// Cria Browse
		oBrows := TCBrowse():New( 01, 01, 310, 156,, {PadR('Status',60),PadR('Usuário',30),PadR('Data',10),PadR('Hora',10),PadR('Origem',25) },{20,50,50,50},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
		// Seta vetor para a browse
		oBrows:SetArray(aBrows) 
	
		// Monta a linha a ser exibida no Browse
		oBrows:bLine := {||{ aBrows[ oBrows:nAt, 01 ], aBrows[ oBrows:nAt, 02 ], aBrows[ oBrows:nAT, 03 ], aBrows[ oBrows:nAT, 04 ], aBrows[ oBrows:nAT, 05 ] } }
	
		// Evento de clique no cabeçalho da browse
		oBrows:bHeaderClick := {|| Nil } 
	
		// Evento de duplo click na celula
		oBrows:bLDblClick   := {|| Nil }
	
		ACTIVATE DIALOG oDlg2 CENTERED 

	Else                
	
		MsgAlert( "Nenhum log registrado para o PV: "+ aPV[ 01 ] +" Item:"+aPV[ 02 ] )
	EndIf

Return

// ##################################
// Cria as perguntas para o filtro ##
// ##################################
Static Function AjustaSX1( cPerg )

	PutSx1( cPerg, "01", "Do Status ?          ","","","mv_ch1","C",02,00,00,"G" ,"","Z0 ","","","MV_PAR01","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02", "Até Status ?         ","","","mv_ch2","C",02,00,00,"G" ,"","Z0 ","","","MV_PAR02","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03", "Do Vendedor ?        ","","","mv_ch3","C",06,00,00,"G" ,"","SA3","","","MV_PAR03","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04", "Até Vendedor ?       ","","","mv_ch4","C",06,00,00,"G" ,"","SA3","","","MV_PAR04","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05", "Do Pedido de Venda ? ","","","mv_ch5","C",06,00,00,"G" ,"","SC5","","","MV_PAR05","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06", "Até Pedido de Venda ?","","","mv_ch6","C",06,00,00,"G" ,"","SC5","","","MV_PAR06","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "07", "Do Cliente ?         ","","","mv_ch7","C",06,00,00,"G" ,"","SA1","","","MV_PAR07","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "08", "Até Cliente ?        ","","","mv_ch8","C",06,00,00,"G" ,"","SA1","","","MV_PAR08","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "09", "Do Produto ?         ","","","mv_ch9","C",30,00,00,"G" ,"","SB1","","","MV_PAR09","","","","","","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "10", "Até Produto ?        ","","","mv_chA","C",30,00,00,"G" ,"","SB1","","","MV_PAR10","","","","","","","","","","","","","","","","","","","","")

Return

// #############################################################
// Verifica se usuário logado é vendedor e retorna .T. ou .F. ##
// #############################################################
Static Function Vender()

	Local _lRet   := .F.
	Local _cCod   := ""
	Local _Estilo := ""
	
	dbSelectArea("SA3")
	dbSetOrder(7)

	If dbSeek( xFilial("SA3") + RetCodUsr() )
   	   _lRet   := .T.
	   _cCod   := SA3->A3_COD
       _Estilo := SA3->A3_TSTAT
	EndIf

    If Empty( Alltrim(_Estilo) )
       _Estilo := "1"
    Endif
	
Return( { _lRet, _cCod, _Estilo } )

// ###############
// Cor da linha ##
// ###############
Static Function GetColor( cPedido )

	Local nRet  := 0

	msgalert(cpedido)
	msgalert(cpedatu)
	msgalert(nCor)
	msgalert(nRet)
	
	If cPedido != cPedAtu
		nRet := Iif( nCor == 16776960, 16777215, 16776960 )
		nCor := nRet
		cPedAtu := cPedido
	Else
		nRet := nCor
	Endif
	
Return nRet

// ##########################################################################
// Função que pesquisa o saldo do produto ou componente conforme parâmetro ##
// ##########################################################################
Static Function kSaldoProd(_Produto)

   If Empty(Alltrim(_Produto))
      MsgAlert("Produto a ser pesquisado inexistente.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + _Produto)

   MaViewSB2(_Produto)

   RestArea( aArea )

Return(.T.)

// ##################################################
// Função que abre o kardex do produto selecionado ##
// ##################################################
Static Function AbreKardexP(kProduto)

   Private cCadastro := "Cadastro de Produtos"
   
   If Empty(Alltrim(kProduto))
      MsgAlert("Produto não selecionado para realizar a consulta do Kardex.")
      Return(.T.)
   Endif
          
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek( xFilial("SB1") + kProduto )
   
   U_AUTOM181()
   
Return(.T.)