#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR01.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 11/07/2011                                                          ##
// Objetivo..: Impressão do Chamado Técnico / Ordem de Serviço	                   ##
// Parâmetros: Nr. da Ordem de Serviço a ser Impressa                              ##
// Retorno...: Sem Retorno                                                         ##
// Autor.....: Pietro Lopes                                                        ##
// Data......: 03/07/2018                                                          ##
// ##################################################################################

User Function AUTOMR01(_EmLote)   
 
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""

   Local oMemo1
   Local oMemo2

   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6

   Private aFiliais	   := {}
   Private aTipoDoc	   := {}
   Private aTipoImp	   := {}
   Private cOrdem      := IIF(_EmLote == Nil, M->AB6_NUMOS, U_P_CORTA(_EmLote,"|", 1))
   Private cCliente	   := IIF(_EmLote == Nil, M->AB6_RESPA, U_P_CORTA(_EmLote,"|", 2))
   Private xAssinatura := ""
   Private nVias       := 1

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private oGet1
   Private oGet2

   Private oDlg

   // ######################################################################################
   // Imprime a OS caso este programa for chamado pela tela de Envio de Work Flow wm Lote ##
   // ######################################################################################
   If _EmLote == Nil
   Else
      ImprimeOS(cOrdem, 1, "Ordem de Serviço", "Gráfica", cFilAnt)
      Return(.T.)
   Endif   

   // ######################################################
   // Carrega o combo das Filiais conforme Empresa logada ##
   // ######################################################
   aFiliais  := U_AUTOM539(2, cEmpAnt)

   // ########################################
   // Carrega o combo de Tipo de Documentos ##
   // ########################################
   aTipoDoc := {"Chamado Técnico","Ordem de Serviço"}      

   // #######################################
   // Carrega o combo de Tipo de Impressão ##
   // #######################################
   aTipoImp := {"Gráfica","Matricial"}

   // ###################################
   // Pesquisa a assinatura do cliente ##
   // ###################################     
   //ATUALIZACAO REALIZADA POR SOSYS #4981
   If ExistDir( "p:\foto_OS")
	   If File("p:\foto_OS\" + cEmpAnt + M->AB6_FILIAL + M->AB6_NUMOS + "A.png")
	      xAssinatura := "p:\foto_OS\" + cEmpAnt + M->AB6_FILIAL + M->AB6_NUMOS + "A.png"   
	   Else
	      xAssinatura := ""
	   Endif
   Else
   		xAssinatura := ""
   EndIf
   //FIM ATUALIZACAO 
   
   DEFINE MSDIALOG oDlg TITLE "Impressão Chamdo Técnico/Ordem de Serviço" FROM C(178),C(181) TO C(514),C(679) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(240),C(001) PIXEL OF oDlg
   @ C(147),C(002) GET oMemo2 Var cMemo2 MEMO Size C(240),C(001) PIXEL OF oDlg
   @ C(045),C(128) GET oMemo3 Var cMemo3 MEMO Size C(115),C(001) PIXEL OF oDlg
   @ C(045),C(128) GET oMemo4 Var cMemo4 MEMO Size C(001),C(083) PIXEL OF oDlg
   @ C(127),C(128) GET oMemo5 Var cMemo5 MEMO Size C(114),C(001) PIXEL OF oDlg
   @ C(046),C(242) GET oMemo6 Var cMemo6 MEMO Size C(001),C(082) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Filial"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(128) Say "Assinatura do Cliente"            Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Nº Ordem Serviço"                 Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(005) Say "Tipo de Documento a ser impresso" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(005) Say "Tipo de Impressão"                Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(124),C(005) Say "Nome Completo Assinatura"         Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlg
            
   @ C(045),C(005) ComboBox cComboBx1 Items aFiliais Size C(118),C(010)                              PIXEL OF oDlg
   @ C(066),C(005) MsGet    oGet1     Var   cOrdem   Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(088),C(005) ComboBox cComboBx2 Items aTipoDoc Size C(118),C(010)                              PIXEL OF oDlg
   @ C(111),C(005) ComboBox cComboBx3 Items aTipoImp Size C(118),C(010)                              PIXEL OF oDlg
   @ C(133),C(005) MsGet    oGet2     Var   cCliente Size C(116),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(047),C(130) Jpeg FILE xAssinatura          Size C(110),C(079) PIXEL NOBORDER OF oDlg
   @ C(152),C(084) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )
   @ C(152),C(123) Button "Imprimir"              Size C(037),C(012) PIXEL OF oDlg ACTION( ImprimeOS(cOrdem, nVias, cComboBx2, cComboBx3, cComboBx1))
   @ C(131),C(127) Button "Visualizar Assinatura" Size C(115),C(012) PIXEL OF oDlg ACTION( AmpliaAssi())
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################################
// Funcção que gera a impressão do Chamado Técnico / Ordem de Serviço ##
// #####################################################################
Static Function ImprimeOS( _cNumOS, nVias, cTipo, cImpressao, _Filial )

	Local cQuery       := ""
	Local aStru        := {}
	Local _cPedAtu     := ""
	Local _lPrimeiro   := .T.
    Local cSql         := ""
    Local nContador    := 10
    Local xLinhas      := 0
    Local cTexto1 	   := ""
    Local cTexto2      := ""
    Local dData        := ""
    Local cComentario  := ""
    Local nProdutos    := 0
    Local nServicos    := 0
    Local cCondicao    := ""
    Local nFonte       := 0
    Local cLaudo       := ""
    Local xLinha       := ""

    Local kVoltar      := .F.
    Local lChumba      := .F.
	Local lEditaLaudo  := .F.
    Local cMemo1	   := ""
    Local cLaudoTec    := ""
    Local cLaudoAss    := ""
    Local cRegua01     := "         1         2         3         4         5         6         7         8         9       100       110       120       130     "
    Local cRegua02     := "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345"
    Local cRegua03     := "         1         2         3         4         5         6         7"
    Local cRegua04     := "1234567890123456789012345678901234567890123456789012345678901234567890"

    Local oMemo1
    Local oMemo2
    Local oMemo3
    Local oMemo4    

    Local oMemo5    
    Local oMemo6    
    Local oMemo7        

    If Alltrim(cImpressao) == "Gráfica"
       nFonte := 1
    Else
       nFonte := 2
    Endif
	                 
    Private oDlgLaudo

	Private aObs       := {}
	Private cObs       := ""
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nLin      := 0
	Private _nCotDia   := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private _cPrazoPag := ""
	Private _nMoeda    := 1
    Private _Moeda     := 0
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21
	Private _cMemo7    := ""

    // ############################################################
    // Gera consistência dos dados informados antes da impressão ##
    // ############################################################
    If Empty(_cNumOS)
       Msgalert("Número Ordem de Serviço não selecionadO.")
       Return nil
    Endif
       
    If nVias == 0
       Msgalert("Nº de Vias a serem impressas não informada.")
       Return nil
    Endif

    // #############################
	// Cria o objeto de impressão ##
	// #############################
	oPrint := TmsPrinter():New()
	
    // #########################################
	// Orientação da página                   ##
	// oPrint:SetLandScape() // Para Paisagem ##
	// #########################################
	oPrint:SetPortrait()    // Para Retrato
	
    // ##################################
	// Tamanho da página na impressão  ##
	// oPrint:SetPaperSize(8) // A3    ##
	// oPrint:SetPaperSize(1) // Carta ##
	// ##################################
	oPrint:SetPaperSize(9)   // A4
	
    // ###########################################################################
	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio ##
	// ###########################################################################
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20   := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )
	oFont21   := TFont():New( "Courier New",,07,,.t.,,,,.f.,.f. )

    // #####################################################
	// Pesquisa o nome da Empresa/Filial para o cabecalho ##
	// #####################################################
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

    // ####################################################
    // Monta o SQL conforme seleção do tipo de impressão ##
    // ####################################################	
    If Select("RESULTADO") > 0
       RESULTADO->( dbCloseArea() )
    EndIf

    If Alltrim(cTipo) == "Chamado Técnico"
	   cSql := ""
	   cSql := "SELECT AB6.AB6_NUMOS , "  + chr(13) // 01 - Numero Os
       cSql	+= "  	   AB6.AB6_EMISSA, "  + chr(13) // 02 - Data de emissão
       cSql	+= " 	   AB6.AB6_HORA  , "  + chr(13) // 03 - Hora da emissão
       cSql	+= " 	   AB6.AB6_CODCLI, "  + chr(13) // 04 - Código do Cliente
       cSql	+= " 	   AB6.AB6_LOJA  , "  + chr(13) // 05 - Loja do Cliente
       cSql	+= " 	   SA1.A1_COD    , "  + chr(13) // 06 - Código do Cliente
       cSql += "       SA1.A1_LOJA   , "  + CHR(13)
       cSql	+= " 	   SA1.A1_NOME   , "  + chr(13) // 07 - Nome do Cliente
       cSql	+= " 	   SA1.A1_END    , "  + chr(13) // 08 - Endereço do Cliente
       cSql	+= " 	   SA1.A1_BAIRRO , "  + chr(13) // 09 - Bairro do Cliente
       cSql	+= " 	   SA1.A1_MUN    , "  + chr(13) // 10 - Municipio do Cliente
       cSql	+= " 	   SA1.A1_EST    , "  + chr(13) // 11 - Estado (UF) do cliente
       cSql	+= " 	   SA1.A1_DDD    , "  + chr(13) // 12 - DDD do telefone do cliente
       cSql	+= " 	   SA1.A1_TEL    , "  + chr(13) // 13 - Telefone do Cliente
       cSql	+= " 	   SA1.A1_CGC    , "  + chr(13) // 13 - Telefone do Cliente
//     cSql	+= " 	   C.AB2_NRCHAM  , "  + chr(13) // 14 - Nº do Chamado técnico
       cSql	+= "       AB7.AB7_CODPRO, "  + chr(13) // 15 - Código do Produto
       cSql	+= " 	   AB7.AB7_NUMSER, "  + chr(13) // 16 - Nº de série do produto
       cSql	+= " 	   AB6.AB6_COMC  , "  + chr(13) // 17 - Observações do Cliente
       cSql	+= " 	   SB1.B1_COD    , "  + chr(13) // 21 - Código do produto   
       cSql	+= " 	   SB1.B1_DESC   , "  + chr(13) // 22 - Descrição do produto
       cSql	+= "  	   AA3.AA3_CODPRO, "  + chr(13) // 23 - Código do produto
       cSql	+= "	   AA3.AA3_NUMSER, "  + chr(13) // 24 - Nº de série do produto
       cSql	+= "	   AA3.AA3_MODELO, "  + chr(13) // 25 - Modelo do produto do chamado técnico
       cSql += "       SA1.A1_CEP    , "  + chr(13) // 26 - CEP do endereço do cliente
       cSql += "       SA1.A1_EMAIL  , "  + chr(13) // 27 - E-Mail do Cliente
       cSql += "       SA1.A1_FAX    , "  + chr(13) // 28 - Fax do Cliente
       cSql += "       AB6.AB6_ATEND , "  + chr(13) // 29 - Nome do Atendente (Técnico)
       cSql += "       AB6.AB6_CONTWF, "  + chr(13) // 30 - Nome do Contato do Cliente
       cSql += "       AB6.AB6_NFENT , "  + chr(13) // 31 - Nº Nota Fiscal de Entrada do Cliente
       cSql += "       AB6.AB6_RLAUDO  "  + chr(13) // 32 - Código do técnico
       cSql	+= "  FROM " + RetSqlName("AB6") + " AB6 (NOLOCK), " +chr(13) 
       cSql	+= "       " + RetSqlName("SA1") + " SA1 (NOLOCK), " +chr(13)

       cSql	+= "       " + RetSqlName("AB7") + " AB7 (NOLOCK), " +chr(13)
       cSql	+= "       " + RetSqlName("SB1") + " SB1 (NOLOCK), " +chr(13)
       cSql	+= "       " + RetSqlName("AA3") + " AA3 (NOLOCK)  " +chr(13)
       cSql	+= " WHERE AB6.AB6_CODCLI = SA1.A1_COD    " + chr(13)
       cSql	+= "   AND AB6.AB6_LOJA   = SA1.A1_LOJA   " + chr(13)
       cSql	+= "   AND AB6.AB6_NUMOS  = AB7.AB7_NUMOS " + chr(13)
       cSql	+= "   AND AB7.AB7_CODPRO = SB1.B1_COD    " + chr(13)
       cSql	+= "   AND AB7.AB7_CODPRO = AA3.AA3_CODPRO" + chr(13)
       cSql	+= "   AND AB7.AB7_NUMSER = AA3.AA3_NUMSER" + chr(13)
 	   cSql += "   AND AB6.AB6_NUMOS  = '" + Alltrim(_cNumOS)                 + "' " + chr(13)
       cSql += "   AND AB6.AB6_FILIAL = '" + Alltrim(Substr(_Filial,01,02))   + "'"  + chr(13)
       cSql += "   AND AB7.AB7_FILIAL = '" + Alltrim(Substr(_Filial,01,02))   + "'"  + chr(13)
       cSql += "   AND AB6.D_E_L_E_T_ = '' "+chr(13)
       cSql += "   AND AB7.D_E_L_E_T_ = '' "+chr(13)
       cSql += "   AND SB1.D_E_L_E_T_ = '' "+chr(13)
       cSql += "   AND SA1.D_E_L_E_T_ = '' "+chr(13)
              
    Else

       cSql := ""
       cSql := "SELECT AB6.AB6_NUMOS , " + CHR(13)
       cSql += "       AB6.AB6_CODCLI , " + CHR(13)
       cSql += "       AB6.AB6_LOJA   , " + CHR(13)
       cSql += "       AB6.AB6_EMISSA , " + CHR(13)
       cSql += "       AB6.AB6_HORA   , " + CHR(13)
       cSql += "       AB6.AB6_RLAUDO , " + CHR(13)
       cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB6.AB6_MEMO7 )) AS LAUDO, " + CHR(13)
       cSql += "       AB6.AB6_MLAUDO , " + CHR(13)
       cSql += "       AB6.AB6_MINTER , " + CHR(13)
       cSql += "       AB6.AB6_MEMO7  , " + CHR(13)
       cSql += "       SA1.A1_COD     , " + CHR(13)
       cSql += "       SA1.A1_LOJA    , " + CHR(13)
       cSql += "       SA1.A1_NOME    , " + CHR(13)
       cSql += "       SA1.A1_END     , " + CHR(13)
       cSql += "       SA1.A1_BAIRRO  , " + CHR(13)
       cSql += "       SA1.A1_MUN     , " + CHR(13)
       cSql += "       SA1.A1_EST     , " + CHR(13)
       cSql += "       SA1.A1_DDD     , " + CHR(13)
       cSql += "       SA1.A1_TEL     , " + CHR(13)
       cSql	+= " 	   SA1.A1_CGC     , " + chr(13)
       cSql += "       AB7.AB7_NUMOS  , " + CHR(13)
       cSql += "       AB7.AB7_FILIAL , " + CHR(13)
       cSql += "       AB7.AB7_CODPRO , " + CHR(13)
       cSql += "       AB7.AB7_CODPRB , " + CHR(13)
       cSql += "       AB7.AB7_NUMSER , " + CHR(13)
       cSql += "       SB1.B1_COD     , " + CHR(13)
       cSql += "       SB1.B1_DESC    , " + CHR(13)
       cSql += "       AB6.AB6_CONPAG , " + CHR(13)
       cSql += "       SE4.E4_DESCRI  , " + CHR(13)
       cSql += "       SA1.A1_CEP     , " + CHR(13)
       cSql += "       SA1.A1_EMAIL   , " + CHR(13)
       cSql += "       SA1.A1_FAX     , " + CHR(13)
       cSql += "       AB6.AB6_NFENT  , " + CHR(13)
       cSql += " (SELECT TOP(1) AA3.AA3_MODELO FROM " + RetSqlName("AA3") + " AA3 WHERE AA3.AA3_FILIAL = '" + Alltrim(Substr(_Filial,01,02)) + "' AND AA3.AA3_CODCLI = AB6.AB6_CODCLI " 
       cSql += " AND AA3.AA3_LOJA = AB6.AB6_LOJA AND AA3.D_E_L_E_T_ = '' AND AA3.AA3_CODPRO = AB7.AB7_CODPRO AND AA3.AA3_NUMSER = AB7.AB7_NUMSER) AS AA3_MODELO "+ CHR(13)
       cSql += " FROM " + RetSqlName("AB6") + " AB6 (NOLOCK) " + CHR(13)
       cSql += " INNER JOIN " + RetSqlName("AB7") + " AB7 (NOLOCK) ON AB7.AB7_NUMOS = AB6.AB6_NUMOS  AND AB7.AB7_FILIAL = '" + Alltrim(Substr(_Filial,01,02))  + "' AND AB7.D_E_L_E_T_='' " + CHR(13)
       cSql += " INNER JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON SA1.A1_COD = AB6.AB6_CODCLI  AND SA1.A1_LOJA = AB6.AB6_LOJA  AND SA1.D_E_L_E_T_='' "+ CHR(13)    
       cSql += " INNER JOIN " + RetSqlName("SE4") + " SE4 (NOLOCK) ON SE4.E4_CODIGO = AB6.AB6_CONPAG AND SE4.D_E_L_E_T_='' "+ CHR(13)    
       cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON AB7.AB7_CODPRO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "+ CHR(13)
       cSql += " WHERE AB6.AB6_NUMOS = '" + Alltrim(_cNumOs) + "'" + CHR(13)
	   cSql += " AND AB6.AB6_FILIAL = '" + Alltrim(Substr(_Filial,01,02))  + "' AND AB6.D_E_L_E_T_ = '' " + CHR(13)
       
      Endif
   
	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "RESULTADO", .T., .T. )
	
	  // ######################################### 
      // Verifica se existe resultado na tabela ##
      // #########################################
  	  RESULTADO->( dbGoTop() )

      If Alltrim(cTipo) == "Chamado Técnico"
         If Empty(Alltrim(RESULTADO->AB6_NUMOS))
            MsgAlert("Não existem dados a serem visualizados para este Numero de Ordem de Serviço.")
            RESULTADO->( dbCloseArea() )
   	        Return Nil
   	     Endif
   	  Else   
         If Empty(Alltrim(RESULTADO->AB6_NUMOS))
            MsgAlert("Não existem dados a serem visualizados para este Numero de Ordem de Serviço.")
            RESULTADO->( dbCloseArea() )
   	        Return Nil
   	     Endif
      Endif
      
      // ##########################################
      // Pesquisa a situação da Ordem de Serviço ##
      If Alltrim(cTipo) == "Chamado Técnico"    
      Else

         If Select("T_OCORRENCIA") > 0
            T_OCORRENCIA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT AAG_CODPRB,"
         cSql += "       AAG_STAT   "
         cSql += "  FROM " + RetSqlName("AAG")
         cSql += " WHERE AAG_CODPRB = '" + Alltrim(Resultado->AB7_CODPRB) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIA", .T., .T. )

         Do Case
            Case T_OCORRENCIA->AAG_STAT == "N"
                 __Situacao := "NORMAL"               
            Case T_OCORRENCIA->AAG_STAT == "G"
                 __Situacao := "GARANTIA"               
            Case T_OCORRENCIA->AAG_STAT == "P"
                 __Situacao := "GARANTIA PARCIAL"               
            OtherWise
                 __Situacao := "NORMAL"                                
         EndCase
     
      Endif   

      // #################################
      // Volta para o primeiro registro ##
      // #################################
      RESULTADO->( dbGoTop() )

      // ###################### 
      // Início do relatório ##
      // ######################
      oPrint:StartPage()
	
      // ##################################### 
      // Logotipo e identificação do pedido ##
      // #####################################
      oPrint:SayBitmap( 0030, 0100, "logoautoma.bmp", 0700, 0200 )
    
      If Alltrim(cTipo) == "Chamado Técnico"
         oPrint:Say( 0150, 1500, "A T E N D I M E N T O", oFont10  )
         oPrint:Say( 0140, 2070, RESULTADO->AB6_NUMOS  , oFont16b )
      Else
         cCondicao := RESULTADO->E4_DESCRI
         oPrint:Say( 0150, 1500, "O R D E M  D E  S E R V I Ç O", oFont10  )
         oPrint:Say( 0140, 2070, RESULTADO->AB6_NUMOS          , oFont16b )
         oPrint:Say( 0190, 1500, "SITUAÇÃO: " + __Situacao, oFont10  )
      Endif
              
      //oPrint:Line( 0240, 0100, 0240, 2400 )
      oPrint:Line( 0240, 1500, 0240, 2400 )

      dbSelectArea("SM0")
      SM0->( DbSeek( cEmpAnt + Substr(_Filial,01,02) ) )	
      
      // ####################
      // Dados de cadastro ##
      // ####################
      oPrint:Say( 0200, 0330, AllTrim( SM0->M0_NOME ), IIF(nFonte == 1, oFont10b, oFont20))

      Do Case
         Case cEmpAnt == "01"
              oPrint:Say( 0200, 0330, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", IIF(nFonte == 1, oFont10b, oFont20))
         Case cEmpAnt == "02"
              oPrint:Say( 0200, 0330, "TI AUTOMAÇÃO LTDA", IIF(nFonte == 1, oFont10b, oFont20))
         Case cEmpAnt == "03"
              oPrint:Say( 0200, 0330, "ATECH", IIF(nFonte == 1, oFont10b, oFont20))
      EndCase            

      oPrint:Say( 0250, 0100, "Endereço:" , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0300, 0100, "CNPJ:"     , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0350, 0100, "E-mail:"   , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0250, 1500, "Cidade:"   , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0300, 1500, "Estado:"   , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0350, 1500, "Fone/Fax:" , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0400, 1500, "Emissão:"  , IIF(nFonte == 1, oFont10, oFont20))
  
      oPrint:Say( 0250, 0330, AllTrim( SM0->M0_ENDENT ) +" "+ AllTrim( SM0->M0_COMPENT ), IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Say( 0300, 0330, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), IIF(nFonte == 1, oFont10b, oFont20))

      Do Case
         Case cEmpAnt == "01"
              oPrint:Say( 0350, 0330, "orcamento@automatech.com.br", IIF(nFonte == 1, oFont10b, oFont20))
         Case cEmpAnt == "02"
              oPrint:Say( 0350, 0330, "orcamento.curitiba@automatech.com.br", IIF(nFonte == 1, oFont10b, oFont20))            
         Otherwise 
              oPrint:Say( 0350, 0330, "orcamento@automatech.com.br", IIF(nFonte == 1, oFont10b, oFont20))            
      EndCase            

      oPrint:Say( 0250, 1730, SM0->M0_CIDENT, IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Say( 0300, 1730, SM0->M0_ESTENT, IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Say( 0350, 1730, Transform( SM0->M0_TEL, "@R (99) 9999-9999" )+"/"+Transform( SM0->M0_FAX, "@R (99) 9999-9999" ), IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Say( 0400, 1730, DtoC( dDataBase ) +" "+ Time(), IIF(nFonte == 1, oFont10b, oFont20))

      oPrint:Line( 0425, 0100, 0425, 1450 )
      oPrint:Line( 0450, 1500, 0450, 2400 )
	
      // ######################
      // Dados do fornecedor ##
      // ######################
      oPrint:Say( 0450, 0100, "Cliente:" , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0500, 0100, "CNPJ/CPF:", IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0550, 0100, "Endereço:", IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0600, 0100, "E-mail:"  , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0500, 1500, "Fone/Fax:", IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0550, 1500, "Cidade:"  , IIF(nFonte == 1, oFont10, oFont20))
      oPrint:Say( 0600, 1500, "Estado:"  , IIF(nFonte == 1, oFont10, oFont20))

      If Len(Alltrim(RESULTADO->A1_CGC)) == 14
         KCNPJ := Substr(RESULTADO->A1_CGC,01,02) + "." + ;
                  Substr(RESULTADO->A1_CGC,03,03) + "." + ;    
                  Substr(RESULTADO->A1_CGC,06,03) + "/" + ;
                  Substr(RESULTADO->A1_CGC,09,04) + "/" + ;                
                  Substr(RESULTADO->A1_CGC,13,02)
      Else
         KCNPJ := Substr(RESULTADO->A1_CGC,01,03) + "." + ;
                  Substr(RESULTADO->A1_CGC,04,03) + "." + ;    
                  Substr(RESULTADO->A1_CGC,07,03) + "-" + ;
                  Substr(RESULTADO->A1_CGC,11,02)
      Endif                    
                
      If Alltrim(cTipo) == "Chamado Técnico"
         oPrint:Say( 0450, 0330, RESULTADO->A1_COD + "." + RESULTADO->A1_LOJA + " - "+ RESULTADO->A1_NOME, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0500, 0330, KCNPJ, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0550, 0330, AllTrim( RESULTADO->A1_END ) +" "+ AllTrim( RESULTADO->A1_BAIRRO ) +" "+ Transform( AllTrim( RESULTADO->A1_CEP ), "@R 99999-999"), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0600, 0330, AllTrim( RESULTADO->A1_EMAIL ), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0500, 1730, Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_FAX, "@R (99) 9999-9999" ), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0550, 1730, RESULTADO->A1_MUN, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0600, 1730, RESULTADO->A1_EST, IIF(nFonte == 1, oFont10b, oFont20))
      Else
         oPrint:Say( 0450, 0330, RESULTADO->A1_COD + "." + RESULTADO->A1_LOJA + " - "+ RESULTADO->A1_NOME, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0500, 0330, KCNPJ, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0550, 0330, AllTrim( RESULTADO->A1_END )   +" " + AllTrim( RESULTADO->A1_BAIRRO ) +" "+ Transform( AllTrim( RESULTADO->A1_CEP ), "@R 99999-999"), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0600, 0330, AllTrim( RESULTADO->A1_EMAIL ), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0500, 1730, Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( RESULTADO->A1_DDD ) + RESULTADO->A1_FAX, "@R (99) 9999-9999" ), IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0550, 1730, RESULTADO->A1_MUN, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0600, 1730, RESULTADO->A1_EST, IIF(nFonte == 1, oFont10b, oFont20))
      Endif

      oPrint:Line( 0650, 0100, 0650, 2400 )
	
      If Alltrim(cTipo) == "Chamado Técnico"      
         dData := Substr(Resultado->AB6_EMISSA,07,02) + "/" + Substr(Resultado->AB6_EMISSA,05,02) + "/" + Substr(Resultado->AB6_EMISSA,01,04)
         oPrint:Say( 0680, 0100, "Incluído em:", IIF(nFonte == 1, oFont10, oFont20))
         oPrint:Say( 0680, 0330, dData + " - " + RESULTADO->AB6_HORA, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0680, 1500, "NF Entrada:", IIF(nFonte == 1, oFont10, oFont20))
         oPrint:Say( 0680, 1730, RESULTADO->AB6_NFENT, IIF(nFonte == 1, oFont10b, oFont20))
      Else
         dData := Substr(Resultado->AB6_EMISSA,07,02) + "/" + Substr(Resultado->AB6_EMISSA,05,02) + "/" + Substr(Resultado->AB6_EMISSA,01,04)
         oPrint:Say( 0680, 0100, "Incluído em:", IIF(nFonte == 1, oFont10, oFont20))
         oPrint:Say( 0680, 0330, dData + " - " + RESULTADO->AB6_HORA, IIF(nFonte == 1, oFont10b, oFont20))
         oPrint:Say( 0680, 1500, "NF Entrada:", IIF(nFonte == 1, oFont10, oFont20))
         oPrint:Say( 0680, 1730, RESULTADO->AB6_NFENT, IIF(nFonte == 1, oFont10b, oFont20))
      Endif       

      oPrint:Line( 0750, 0100, 0750, 2400 )
      oPrint:Say(  0780, 00330, "D A D O S  D O  E Q U I P A M E N T O", IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Say(  0780, 01550, "COMENTÁRIOS/ACESSÓRIOS", IIF(nFonte == 1, oFont10b, oFont20))
      oPrint:Line( 0850, 0100, 0850, 2400 )
            
      // ########################################
      // Pesquisa os Acessórios do Equipamento ##
      // ########################################
      If Alltrim(cTipo) == "Chamado Técnico"      
         
         cNota01 := ""
         cNota02 := ""
         cNota03 := ""
         cNota04 := ""
         cNota05 := ""
         cNota06 := ""
         cNota07 := ""    

         If Select("T_COMENTARIO") > 0
            T_COMENTARIO->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT AB6.AB6_NUMOS , "+chr(13)
         cSql += "       AB7.AB7_MEMO  , "+chr(13)
         cSql += "       AB7.AB7_MEMO1  , "+chr(13)
         cSql += "       SYP.YP_TEXTO    "+chr(13)
         cSql += "  FROM " + RetSqlName("AB6") + " AB6, "+chr(13)
         cSql += "       " + RetSqlName("AB7") + " AB7, "+chr(13)
         cSql += "       " + RetSqlName("SYP") + " SYP "+chr(13)  
         cSql += "   WHERE AB6_NUMOS   = '"+Alltrim(_cNumOS)+"' " +chr(13)
         cSql += "   AND AB7.AB7_NUMOS   = AB6.AB6_NUMOS " +chr(13)
         cSql += "   AND SYP.YP_CHAVE     = AB7.AB7_MEMO1   "+chr(13) //AB6.AB6_MEMO5     
         cSql += "   AND SYP.YP_FILIAL    = '  '         "+chr(13)
         cSql += "   AND AB6.AB6_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
         cSql += "   AND AB7.AB7_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
         cSql += "   AND AB6.D_E_L_E_T_ = ''       "+chr(13)
         cSql += "   AND AB7.D_E_L_E_T_ = ''       "+chr(13)
         //ATUALIZAÇÃO REALIZADA POR SOSYS #4981
         cSql += "   AND SYP.D_E_L_E_T_ = ''       "+chr(13)
         //FIM ATUALIZACAO
//       cSql += "   AND SYP.YP_TEXTO    <> '\13\10' "+chr(13)

 	     cSql := ChangeQuery( cSql )
 	     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

//       If !T_COMENTARIO->( EOF() )
//   
//          nContar := 1
//
//          While !T_COMENTARIO->( Eof() )
//             j := Strzero(nContar,2)
//             cNota&j := StrTran(StrTran(StrTran(T_COMENTARIO->YP_TEXTO, "\13\10", ""), CHR(10), ""), CHR(13), "")
//             nContar := nContar + 1
//             T_COMENTARIO->( DbSkip() )
//          Enddo
//
//       Endif

         If !T_COMENTARIO->( EOF() )
   
            xLinha := ""

            While !T_COMENTARIO->( Eof() )
               xLinha := xLinha + Alltrim(Strtran(Strtran(T_COMENTARIO->YP_TEXTO, chr(10), "|"), "\13\10", "|"))
               T_COMENTARIO->( DbSkip() )                        
            Enddo   

            xLinha := xLinha + "|"

            For nContar = 1 to U_P_OCCURS(xLinha, "|", 1)
                If nContar > 7
                   Exit
                Endif
                j       := Strzero(nContar,2)
                cNota&j := U_P_CORTA(xLinha, "|", nContar)
            Next xContar    
         Endif

         T_COMENTARIO->( dbCloseArea() )

      Else
 
/*
         cNota01 := ""
         cNota02 := ""
         cNota03 := ""
         cNota04 := ""
         cNota05 := ""
         cNota06 := ""
         cNota07 := ""    

         If Select("T_COMENTARIO") > 0
            T_COMENTARIO->( dbCloseArea() )
         EndIf

	     cSql := ""
         cSql := "SELECT AB6.AB6_NUMOS , "+chr(13)
         cSql += "       AB7.AB7_MEMO  , "+chr(13)
         cSql += "       AB7.AB7_MEMO1  , "+chr(13)
         cSql += "       SYP.YP_TEXTO    "+chr(13)
         cSql += "  FROM " + RetSqlName("AB6") + " AB6, "+chr(13)
         cSql += "       " + RetSqlName("AB7") + " AB7, "+chr(13)
         cSql += "       " + RetSqlName("SYP") + " SYP "+chr(13)  
         cSql += "   WHERE AB6_NUMOS   = '"+Alltrim(_cNumOS)+"' " +chr(13)
         cSql += "   AND AB7.AB7_NUMOS   = AB6.AB6_NUMOS " +chr(13)
         cSql += "   AND SYP.YP_CHAVE     = AB7.AB7_MEMO1   "+chr(13) // AB6.AB6_MEMO
         cSql += "   AND SYP.YP_FILIAL    = '  '         "+chr(13)
         cSql += "   AND AB6.AB6_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
         cSql += "   AND AB7.AB7_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
         cSql += "   AND AB6.D_E_L_E_T_ = ''       "+chr(13)
         cSql += "   AND AB7.D_E_L_E_T_ = ''       "+chr(13)
//       cSql += "   AND SYP.YP_TEXTO    <> '\13\10' "+chr(13)

   	     cSql := ChangeQuery( cSql )
	     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

         If !T_COMENTARIO->( EOF() )
   
            xLinha := ""

            While !T_COMENTARIO->( Eof() )
               xLinha := xLinha + Alltrim(Strtran(Strtran(T_COMENTARIO->YP_TEXTO, chr(10), "|"), "\13\10", "|"))
               T_COMENTARIO->( DbSkip() )                        
            Enddo   

            xLinha := xLinha + "|"

            For nContar = 1 to U_P_OCCURS(xLinha, "|", 1)
                If nContar > 7
                   Exit
                Endif
                j       := Strzero(nContar,2)
                cNota&j := U_P_CORTA(xLinha, "|", nContar)
            Next xContar    
         Endif

         T_COMENTARIO->( dbCloseArea() )
*/

      Endif

      // #####################################
      // Impressão dos dados do equipamento ##
      // #####################################
      oPrint:Say( 0900, 0100, "Equipamento:", IIF(nFonte == 1, oFont09, oFont20))
      oPrint:Say( 1000, 0100, "Nº de Série:", IIF(nFonte == 1, oFont09, oFont20))

      If Alltrim(cTipo) == "Chamado Técnico"      
         oPrint:Say( 1100, 0100, "Contato....:", IIF(nFonte == 1, oFont09, oFont20))
      Else
         oPrint:Say( 1100, 0100, "Modelo.....:", IIF(nFonte == 1, oFont09, oFont20))
      Endif          

      oPrint:Say( 1200, 0100, "Técnico....:", IIF(nFonte == 1, oFont09, oFont20))
		
      If Alltrim(cTipo) == "Chamado Técnico"      

         // #############################
         // Pesquisa o nome do técnico ##
         // #############################
         If !Empty(RESULTADO->AB6_RLAUDO)
       
            If Select("T_RLAUDO") > 0
               T_RLAUDO->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT AA1_NOMTEC "
            cSql += "  FROM " + RetSqlName("AA1")
            cSql += " WHERE AA1_CODTEC = '" + Alltrim(RESULTADO->AB6_RLAUDO) + "'"
          
            cSql := ChangeQuery( cSql )
	        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RLAUDO", .T., .T. )

            If !T_RLAUDO->( EOF() )
               cRLaudo := T_RLAUDO->AA1_NOMTEC
            Else
               cRlaudo := ""
            Endif
                
            T_RLAUDO->( dbCloseArea() )       
       
         Else
        
            cRlaudo := ""
        
         Endif   

         oPrint:Say( 0900, 0330, "(" + Alltrim(RESULTADO->B1_COD) + ") - " + Alltrim(RESULTADO->B1_DESC), IIF(nFonte == 1, oFont09b, oFont20))
         oPrint:Say( 0900, 1250, cNota01              , IIF(nFonte == 1, oFont09b, oFont09b))
         oPrint:Say( 0950, 1250, cNota02              , IIF(nFonte == 1, oFont09b, oFont09b))
         oPrint:Say( 1000, 0330, RESULTADO->AA3_NUMSER, IIF(nFonte == 1, oFont09b, oFont20))
         oPrint:Say( 1000, 1250, cNota03              , IIF(nFonte == 1, oFont09b, oFont09b))
         oPrint:Say( 1050, 1250, cNota04              , IIF(nFonte == 1, oFont09b, oFont09b))
         oPrint:Say( 1100, 0330, RESULTADO->AB6_CONTWF + " - " + Alltrim(posicione("SU5",1,xFilial("SU5")+RESULTADO->AB6_CONTWF,"U5_CONTAT")), IIF(nFonte == 1, oFont09b, oFont20))
         oPrint:Say( 1100, 1250, cNota05              , IIF(nFonte == 1, oFont09b, oFont09b))
         oPrint:Say( 1150, 1250, cNota06              , IIF(nFonte == 1, oFont09b, oFont09b))

//       oPrint:Say( 1200, 0330, RESULTADO->AB6_ATEND , IIF(nFonte == 1, oFont09b, oFont20))

         oPrint:Say( 1200, 0330, cRlaudo              , IIF(nFonte == 1, oFont09b, oFont20))

         oPrint:Say( 1200, 1250, cNota07              , IIF(nFonte == 1, oFont09b, oFont09b))

      Else

         // ###############################################       
         // Pesquisa o Laudo do Orçamento para Impressão ##
         // ###############################################
         If Select("T_PEGALAUDO") > 0
            T_PEGALAUDO->( dbCloseArea() )
         EndIf
  
         cSql := ""
         cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB6.AB6_MLAUDO )) AS LAUDO "
         cSql += "  FROM " + RetSqlName("AB6") + " AB6 "
         cSql += " WHERE AB6.AB6_FILIAL = '" + Alltrim(Substr(_Filial,01,02))  + "'"
         cSql += "   AND AB6.AB6_NUMOS  = '" + Alltrim(_cNumOS)                + "'"
          
  	     cSql := ChangeQuery( cSql )
	     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEGALAUDO", .T., .T. )

         xMLaudo := IIF(T_PEGALAUDO->( EOF() ), "", T_PEGALAUDO->LAUDO)

         __Posicao := 1
         _cMemo7:= Alltrim(xMLaudo) ////////////////////////////////////_cMemo7:= MsMm(RESULTADO->AB6_MEMO7)
         __Texto0   := StrTran(_cMemo7,chr(13), " ")
         __Texto1   := StrTran(__Texto0,chr(10), " ")
      
//      __Texto0   := StrTran(RESULTADO->LAUDO,chr(13), " ")
//      __Texto1   := StrTran(__Texto0,chr(10), " ")


///*
//       For nContar = 1 to 20
//           j := Strzero(nContar,2)
//           cLaudo&j := Substr(__Texto1,__Posicao,80)
//           __Posicao := __Posicao + 80
//           oPrint:Say( _nLin, 0100, cLaudo&j, IIF(nFonte == 1, oFont20, oFont21))
//           _nLin := _nLin + 35
//       Next nContar    
//
//       // Vertical
//       // oPrint:Line( 1350, 1220, 1890, 1220 )
//
//*/
                                               
        cLaudoTec := _cMemo7

        // #####################################################
        // Pesquisa acessórios para edição antes da impressão ##
        // #####################################################
        cNota01 := ""
        cNota02 := ""
        cNota03 := ""
        cNota04 := ""
        cNota05 := ""
        cNota06 := ""
        cNota07 := ""    

        If Select("T_COMENTARIO") > 0
           T_COMENTARIO->( dbCloseArea() )
        EndIf

	    cSql := ""
        cSql := "SELECT AB6.AB6_NUMOS , "+chr(13)
        cSql += "       AB7.AB7_MEMO  , "+chr(13)
        cSql += "       AB7.AB7_MEMO1  , "+chr(13)
        cSql += "       SYP.YP_TEXTO    "+chr(13)
        cSql += "  FROM " + RetSqlName("AB6") + " AB6, "+chr(13)
        cSql += "       " + RetSqlName("AB7") + " AB7, "+chr(13)
        cSql += "       " + RetSqlName("SYP") + " SYP "+chr(13)  
        cSql += "   WHERE AB6_NUMOS   = '"+Alltrim(_cNumOS)+"' " +chr(13)
        cSql += "   AND AB7.AB7_NUMOS   = AB6.AB6_NUMOS " +chr(13)
        cSql += "   AND SYP.YP_CHAVE     = AB7.AB7_MEMO1   "+chr(13) // AB6.AB6_MEMO
        cSql += "   AND SYP.YP_FILIAL    = '  '         "+chr(13)
        cSql += "   AND AB6.AB6_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
        cSql += "   AND AB7.AB7_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
        cSql += "   AND AB6.D_E_L_E_T_ = ''       "+chr(13)
        cSql += "   AND AB7.D_E_L_E_T_ = ''       "+chr(13)
//      cSql += "   AND SYP.YP_TEXTO    <> '\13\10' "+chr(13)
		//ATUALIZAÇÃO REALIZADA POR SOSYS #4981
        cSql += "   AND SYP.D_E_L_E_T_ = ''       "+chr(13)
        //FIM ATUALIZACAO
         
 	    cSql := ChangeQuery( cSql )
	    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

        If !T_COMENTARIO->( EOF() )
   
           xLinha := ""

           While !T_COMENTARIO->( Eof() )
              xLinha := xLinha + Alltrim(Strtran(Strtran(T_COMENTARIO->YP_TEXTO, chr(10), "|"), "\13\10", "|"))
              T_COMENTARIO->( DbSkip() )                        
           Enddo   

           xLinha := xLinha + "|"

           For nContar = 1 to U_P_OCCURS(xLinha, "|", 1)
               If nContar > 7
                  Exit
               Endif
               j       := Strzero(nContar,2)
               cNota&j := U_P_CORTA(xLinha, "|", nContar)
           Next xContar    

        Endif

        T_COMENTARIO->( dbCloseArea() )

        cLaudoAss := STRTRAN(cNota01, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota02, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota03, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota04, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota05, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota06, "\14\10", "") + CHR(13) + CHR(10)
        cLaudoAss += STRTRAN(cNota07, "\14\10", "") + CHR(13) + CHR(10)

        // ##################################################################################################
        // Abre janela mostrando o laudo técnico possibilitando ao usuário para arrumar antes da impressão ##
        // ##################################################################################################
        kVoltar := .F.
      
        DEFINE MSDIALOG oDlgLaudo TITLE "Laudo Técnico OS" FROM C(178),C(181) TO C(503),C(1050) PIXEL  // 851
   
        @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgLaudo
   
        @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(430),C(001) PIXEL OF oDlgLaudo
   
        @ C(035),C(005) Say "Laudo Técnico"          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgLaudo
        @ C(035),C(275) Say "Comentários/Acessórios" Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgLaudo
                                                          
        @ C(044),C(005) GET oMemo3 Var cRegua01  MEMO Size C(270),C(008) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
        @ C(052),C(005) GET oMemo4 Var cRegua02  MEMO Size C(270),C(009) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
        @ C(060),C(005) GET oMemo2 Var cLaudoTec MEMO Size C(270),C(084) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo

        @ C(044),C(275) GET oMemo5 Var cRegua03  MEMO Size C(155),C(008) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
        @ C(052),C(275) GET oMemo6 Var cRegua04  MEMO Size C(155),C(009) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
        @ C(060),C(275) GET oMemo3 Var cLaudoAss MEMO Size C(155),C(084) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo
   
        @ C(147),C(005) Button "Salvar Alteração Laudo na OS" Size C(089),C(012) PIXEL OF oDlgLaudo 
        @ C(147),C(355) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlgLaudo ACTION( kVoltar := .T., oDlgLaudo:End() )
        @ C(147),C(393) Button "Continuar"                    Size C(037),C(012) PIXEL OF oDlgLaudo ACTION( _cMemo7 := cLaudoTec, oDlgLaudo:End() )
   
        ACTIVATE MSDIALOG oDlgLaudo CENTERED 

        If kVoltar == .T.
           Return(.T.)
        Endif   

        xLaudoAss := STRTRAN(STRTRAN(cLaudoAss, CHR(13), "|"), CHR(10), "")

        cNota01 := U_P_CORTA(xLaudoAss, "|", 1)
        cNota02 := U_P_CORTA(xLaudoAss, "|", 2)
        cNota03 := U_P_CORTA(xLaudoAss, "|", 3)
        cNota04 := U_P_CORTA(xLaudoAss, "|", 4)
        cNota05 := U_P_CORTA(xLaudoAss, "|", 5)
        cNota06 := U_P_CORTA(xLaudoAss, "|", 6)
        cNota07 := U_P_CORTA(xLaudoAss, "|", 7)


//        oPrint:Say( 0900, 0330, "(" + Alltrim(RESULTADO->B1_COD) + ") - " + Alltrim(RESULTADO->B1_DESC), IIF(nFonte == 1, oFont09b, oFont20))
//        oPrint:Say( 0900, 1250, cNota01              , IIF(nFonte == 1, oFont09b, oFont09b))
//        oPrint:Say( 0950, 1250, cNota02              , IIF(nFonte == 1, oFont09b, oFont09b))
//        oPrint:Say( 1000, 0330, RESULTADO->AB7_NUMSER, IIF(nFonte == 1, oFont09b, oFont20))
//        oPrint:Say( 1000, 1250, cNota03              , IIF(nFonte == 1, oFont09b, oFont09b))
//        oPrint:Say( 1050, 1250, cNota04              , IIF(nFonte == 1, oFont09b, oFont09b))
//        oPrint:Say( 1100, 0330, RESULTADO->AA3_MODELO, IIF(nFonte == 1, oFont09b, oFont20))
//        oPrint:Say( 1100, 1250, cNota05              , IIF(nFonte == 1, oFont09b, oFont09b))
//        oPrint:Say( 1150, 1250, cNota06              , IIF(nFonte == 1, oFont09b, oFont09b))

        oPrint:Say( 0900, 0330, "(" + Alltrim(RESULTADO->B1_COD) + ") - " + Alltrim(RESULTADO->B1_DESC), IIF(nFonte == 1, oFont09b, oFont20))
        oPrint:Say( 0900, 1250, cNota01              , IIF(nFonte == 1, oFont20, oFont21))
        oPrint:Say( 0950, 1250, cNota02              , IIF(nFonte == 1, oFont20, oFont21))
        oPrint:Say( 1000, 0330, RESULTADO->AB7_NUMSER, IIF(nFonte == 1, oFont09b, oFont20))
        oPrint:Say( 1000, 1250, cNota03              , IIF(nFonte == 1, oFont20, oFont21))
        oPrint:Say( 1050, 1250, cNota04              , IIF(nFonte == 1, oFont20, oFont21))
        oPrint:Say( 1100, 0330, RESULTADO->AA3_MODELO, IIF(nFonte == 1, oFont09b, oFont20))
        oPrint:Say( 1100, 1250, cNota05              , IIF(nFonte == 1, oFont20, oFont21))
        oPrint:Say( 1150, 1250, cNota06              , IIF(nFonte == 1, oFont20, oFont21))


        // #############################
        // Pesquisa o nome do técnico ##
        // #############################
        If !Empty(RESULTADO->AB6_RLAUDO)
       
           If Select("T_RLAUDO") > 0
              T_RLAUDO->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT AA1_NOMTEC "
           cSql += "  FROM " + RetSqlName("AA1")
           cSql += " WHERE AA1_CODTEC = '" + Alltrim(RESULTADO->AB6_RLAUDO) + "'"
          
       	   cSql := ChangeQuery( cSql )
	       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RLAUDO", .T., .T. )

           If !T_RLAUDO->( EOF() )
              cRLaudo := T_RLAUDO->AA1_NOMTEC
           Else
              cRlaudo := ""
           Endif
                
           T_RLAUDO->( dbCloseArea() )       
       
           oPrint:Say( 1200, 0330, cRlaudo, IIF(nFonte == 1, oFont09b, oFont20))

        Endif   

        oPrint:Say( 1200, 1250, cNota07              , IIF(nFonte == 1, oFont09b, oFont09b))

     Endif    
		
     // ###########
     // Vertical ##
     // ###########
     oPrint:Line( 0750, 1220, 1250, 1220 )

     oPrint:Line( 1250, 0100, 1250, 2400 )

     If Alltrim(cTipo) == "Chamado Técnico"      
//      oPrint:Say( 1270, 0900, ">>>> C O M E N T Á R I O <<<<", IIF(nFonte == 1, oFont10b, oFont20))
     Else
        oPrint:Say( 1270, 1050, "O B S E R V A Ç Õ E S", IIF(nFonte == 1, oFont10b, oFont20))
     Endif          

     oPrint:Line( 1350, 0100, 1350, 2400 )

     // ############################################
     // Imprime as observações do Chamado Técnico ##
     // ############################################
     If Alltrim(cTipo) == "Chamado Técnico"      

//      Resultado-> ( DbGoTop() )

//      _nLin     := 1390
//      nContador := 4
//      While !RESULTADO->( Eof() )
//         If nContador == 0
//            Exit
//         Endif   
  
//         cTexto1 := StrTran(RESULTADO->YP_TEXTO, "\13\10", "")

//         oPrint:Say( _nLin, 0430, cTexto1, IIF(nFonte == 1, oFont09b, oFont20))
//         _nLin     := _nLin + 50
//         nContador := nContador - 1
//         RESULTADO->( dbSkip() )
//      Enddo 

//      _nLin += 50
       
       _nLin := 1250

    Else

       _nLin     := 1390

/*

       // ###############################################       
       // Pesquisa o Laudo do Orçamento para Impressão ##
       // ###############################################
       If Select("T_PEGALAUDO") > 0
          T_PEGALAUDO->( dbCloseArea() )
       EndIf
  
       cSql := ""
       cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB6.AB6_MLAUDO )) AS LAUDO "
       cSql += "  FROM " + RetSqlName("AB6") + " AB6 "
       cSql += " WHERE AB6.AB6_FILIAL = '" + Alltrim(Substr(_Filial,01,02))  + "'"
       cSql += "   AND AB6.AB6_NUMOS  = '" + Alltrim(_cNumOS)                + "'"
          
  	   cSql := ChangeQuery( cSql )
	   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEGALAUDO", .T., .T. )

       xMLaudo := IIF(T_PEGALAUDO->( EOF() ), "", T_PEGALAUDO->LAUDO)

      __Posicao := 1
      _cMemo7:= Alltrim(xMLaudo) ////////////////////////////////////_cMemo7:= MsMm(RESULTADO->AB6_MEMO7)
      __Texto0   := StrTran(_cMemo7,chr(13), " ")
      __Texto1   := StrTran(__Texto0,chr(10), " ")
      
      //__Texto0   := StrTran(RESULTADO->LAUDO,chr(13), " ")
      //__Texto1   := StrTran(__Texto0,chr(10), " ")


///*
//       For nContar = 1 to 20
//           j := Strzero(nContar,2)
//           cLaudo&j := Substr(__Texto1,__Posicao,80)
//           __Posicao := __Posicao + 80
//           oPrint:Say( _nLin, 0100, cLaudo&j, IIF(nFonte == 1, oFont20, oFont21))
//           _nLin := _nLin + 35
//       Next nContar    
//
//       // Vertical
//       // oPrint:Line( 1350, 1220, 1890, 1220 )
//
//*/
                                               

/*
      cLaudoTec := _cMemo7

      // #####################################################
      // Pesquisa acessórios para edição antes da impressão ##
      // #####################################################
      cNota01 := ""
      cNota02 := ""
      cNota03 := ""
      cNota04 := ""
      cNota05 := ""
      cNota06 := ""
      cNota07 := ""    

      If Select("T_COMENTARIO") > 0
         T_COMENTARIO->( dbCloseArea() )
      EndIf

	  cSql := ""
      cSql := "SELECT AB6.AB6_NUMOS , "+chr(13)
      cSql += "       AB7.AB7_MEMO  , "+chr(13)
      cSql += "       AB7.AB7_MEMO1  , "+chr(13)
      cSql += "       SYP.YP_TEXTO    "+chr(13)
      cSql += "  FROM " + RetSqlName("AB6") + " AB6, "+chr(13)
      cSql += "       " + RetSqlName("AB7") + " AB7, "+chr(13)
      cSql += "       " + RetSqlName("SYP") + " SYP "+chr(13)  
      cSql += "   WHERE AB6_NUMOS   = '"+Alltrim(_cNumOS)+"' " +chr(13)
      cSql += "   AND AB7.AB7_NUMOS   = AB6.AB6_NUMOS " +chr(13)
      cSql += "   AND SYP.YP_CHAVE     = AB7.AB7_MEMO1   "+chr(13) // AB6.AB6_MEMO
      cSql += "   AND SYP.YP_FILIAL    = '  '         "+chr(13)
      cSql += "   AND AB6.AB6_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
      cSql += "   AND AB7.AB7_FILIAL   = '" + Alltrim(Substr(_Filial,01,02))    + "'"+chr(13)
      cSql += "   AND AB6.D_E_L_E_T_ = ''       "+chr(13)
      cSql += "   AND AB7.D_E_L_E_T_ = ''       "+chr(13)
      //cSql += "   AND SYP.YP_TEXTO    <> '\13\10' "+chr(13)

 	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

      If !T_COMENTARIO->( EOF() )
   
         xLinha := ""

         While !T_COMENTARIO->( Eof() )
            xLinha := xLinha + Alltrim(Strtran(Strtran(T_COMENTARIO->YP_TEXTO, chr(10), "|"), "\13\10", "|"))
            T_COMENTARIO->( DbSkip() )                        
         Enddo   

         xLinha := xLinha + "|"

         For nContar = 1 to U_P_OCCURS(xLinha, "|", 1)
            
             If nContar > 7
                Exit
             Endif
                 
             j       := Strzero(nContar,2)
             cNota&j := U_P_CORTA(xLinha, "|", nContar)
                
         Next xContar    

      Endif

      T_COMENTARIO->( dbCloseArea() )

      cLaudoAss := STRTRAN(cNota01, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota02, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota03, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota04, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota05, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota06, "\14\10", "") + CHR(13) + CHR(10)
      cLaudoAss += STRTRAN(cNota07, "\14\10", "") + CHR(13) + CHR(10)

      // ##################################################################################################
      // Abre janela mostrando o laudo técnico possibilitando ao usuário para arrumar antes da impressão ##
      // ##################################################################################################
      kVoltar := .F.
      
      DEFINE MSDIALOG oDlgLaudo TITLE "Laudo Técnico OS" FROM C(178),C(181) TO C(503),C(1050) PIXEL  // 851
   
      @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgLaudo
   
      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(430),C(001) PIXEL OF oDlgLaudo
   
      @ C(035),C(005) Say "Laudo Técnico"          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgLaudo
      @ C(035),C(275) Say "Comentários/Acessórios" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgLaudo
                                                           // 325
      @ C(044),C(005) GET oMemo3 Var cRegua01  MEMO Size C(270),C(008) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
      @ C(052),C(005) GET oMemo4 Var cRegua02  MEMO Size C(270),C(009) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
      @ C(060),C(005) GET oMemo2 Var cLaudoTec MEMO Size C(270),C(084) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo

      @ C(044),C(275) GET oMemo5 Var cRegua03  MEMO Size C(155),C(008) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
      @ C(052),C(275) GET oMemo6 Var cRegua04  MEMO Size C(155),C(009) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo When lChumba
      @ C(060),C(275) GET oMemo3 Var cLaudoAss MEMO Size C(155),C(084) FONT IIF(nFonte == 1, oFont20, oFont21) PIXEL OF oDlgLaudo
   
      @ C(147),C(005) Button "Salvar Alteração Laudo na OS" Size C(089),C(012) PIXEL OF oDlgLaudo 
      @ C(147),C(355) Button "Voltar"                       Size C(037),C(012) PIXEL OF oDlgLaudo ACTION( kVoltar := .T., oDlgLaudo:End() )
      @ C(147),C(393) Button "Continuar"                    Size C(037),C(012) PIXEL OF oDlgLaudo ACTION( _cMemo7 := cLaudoTec, oDlgLaudo:End() )
   
      ACTIVATE MSDIALOG oDlgLaudo CENTERED 

      If kVoltar == .T.
         Return(.T.)
      Endif   

      xLaudoAss := STRTRAN(STRTRAN(cLaudoAss, CHR(13), "|"), CHR(10), "")

      cNota01 := U_P_CORTA(xLaudoAss, "|", 1)
      cNota02 := U_P_CORTA(xLaudoAss, "|", 2)
      cNota03 := U_P_CORTA(xLaudoAss, "|", 3)
      cNota04 := U_P_CORTA(xLaudoAss, "|", 4)
      cNota05 := U_P_CORTA(xLaudoAss, "|", 5)
      cNota06 := U_P_CORTA(xLaudoAss, "|", 6)
      cNota07 := U_P_CORTA(xLaudoAss, "|", 7)

*/


      nLaco := U_P_OCCURS(_cMemo7, CHR(10), 1)
       
      If nLaco == 0
         oPrint:Say( _nLin, 0100, Alltrim(_cMemo7), IIF(nFonte == 1, oFont20, oFont21))
         _nLin := _nLin + 35
      Else   
         nLaco := nLaco + 1          
         For nContar = 1 to nLaco
             oPrint:Say( _nLin, 0100, U_P_CORTA(_cMemo7, CHR(10), nContar), IIF(nFonte == 1, oFont20, oFont21))
             _nLin := _nLin + 35
         Next nContar    
      Endif   
     
      // ###########################################
      // Comando comentado conforme tarefa # 3113 ##
      // _nLin := 1890                            ##
      // ###########################################

    Endif

    If Alltrim(cTipo) == "Chamado Técnico"      

       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 35
       oPrint:Say( _nLin, 0800, ">>>> D E S C R I Ç Ã O  D O S  S E R V I Ç O S <<<<", IIF(nFonte == 1, oFont10b, oFont20))
       _nLin += 50
       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 100

       // Caso nContador <> 0, abre linhas para escrever observações
       For xLinhas = 1 to nContador + 16
           oPrint:Line( _nLin, 0100, _nLin, 2300 )       
           _nLin += 50
       Next xLinhas

       _nLin += 50
       
       oPrint:Say( _nLin, 0100, "Total Ordem de Serviço ___________________________", IIF(nFonte == 1, oFont09b, oFont20))
       _nLin += 100
       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 50

       If nFonte == 1
   	      oPrint:Say( _nLin, 0230, "Atesto que acompanhei os serviços prestados acima descritos e estou ciente do valor total da ordem de serviço, que será cobrado", IIF(nFonte == 1, oFont09b, oFont20))
          _nLin += 50
	      oPrint:Say( _nLin, 0230, "através de boleto bancário a ser remetido pelo correio.", IIF(nFonte == 1, oFont09b, oFont20))

          // ##################################
          // Imprime a assinatura do cliente ##
          // ##################################
          If File("p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png")
             kAssinatura := "p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png"
          Else
             kAssinatura := ""
          Endif

          _nLin += 025
          oPrint:SayBitmap( _nLin, 1600, kAssinatura, 0700, 0200 )
          _nLin += 125

       Else
   	      oPrint:Say( _nLin, 0230, "Atesto que acompanhei os serviços prestados acima descritos e estou ciente do valor total da ordem de serviço, que será", IIF(nFonte == 1, oFont09b, oFont20))
          _nLin += 50
	      oPrint:Say( _nLin, 0230, "cobrado através de bancário a ser remetido pelo correio.", IIF(nFonte == 1, oFont09b, oFont20))

          // ##################################
          // Imprime a assinatura do cliente ##
          // ##################################
          If File("p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png")
             kAssinatura := "p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png"
          Else
             kAssinatura := ""
          Endif

          _nLin += 025
          oPrint:SayBitmap( _nLin, 1600, kAssinatura, 0700, 0200 )
          _nLin += 125

       Endif       
          
	   oPrint:Say( _nLin, 0330, "____________________________________", IIF(nFonte == 1, oFont09b, oFont20))
	   oPrint:Say( _nLin, 1650, "____________________________________", IIF(nFonte == 1, oFont09b, oFont20))
       _nLin += 50
	   oPrint:Say( _nLin, 0330, "Local e Data", IIF(nFonte == 1, oFont09b, oFont20))

       If Empty(Alltrim(kAssinatura))
   	      oPrint:Say( _nLin, 1650, "Assinatura Cliente", IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
   	   Else   
	      oPrint:Say( _nLin, 1650, "Assinatura Cliente (Ass. capturada pelo App)", IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
	      oPrint:Say( _nLin, 1650, "Nome: " + Alltrim(M->AB6_RESPA), IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
          oPrint:Say( _nLin, 1650, "Documento: " + Alltrim(M->AB6_NDOCU), IIF(nFonte == 1, oFont09, oFont20))
       Endif       

    Else

       oPrint:Line( _nLin, 0100, 	_nLin, 2400 )
       _nLin += 35
       oPrint:Say( _nLin, 1100, "P R O D U T O S", IIF(nFonte == 1, oFont10b, oFont20))
       _nLin += 50
       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 35

       oPrint:Say( _nLin, 0100, "Código"   , IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 0250, "Descrição", IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 1050, "Und"      , IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 1200, "Qtd"      , IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 1325, "Unitário" , IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 1575, "Sub-Total", IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 1825, "Desconto" , IIF(nFonte == 1, oFont09b, oFont20))
       oPrint:Say( _nLin, 2125, "Total"    , IIF(nFonte == 1, oFont09b, oFont20))

       _nLin += 50
       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 45

       // Pesquisa os produtos e serviços da Ordem de Serviço
       cSql := ""
       cSql := "SELECT AB6.AB6_NUMOS , " + CHR(13) 
       cSql += "       AB6.AB6_MOEDA , " + CHR(13) 
       cSql += "       AB6.AB6_CONPAG, " + CHR(13)
       cSql += "       AB8.AB8_CODPRO, " + CHR(13) 
       cSql += "       AB8.AB8_DESPRO, " + CHR(13) 
       cSql += "       SB1.B1_GDES   , " + CHR(13)
       cSql += "       AB8.AB8_QUANT , " + CHR(13) 
       cSql += "       AB8.AB8_VUNIT , " + CHR(13) 
       cSql += "       AB8.AB8_TOTAL , " + CHR(13) 
       cSql += "       AB8.AB8_PRCLIS, " + CHR(13) 
       cSql += "       AB8.AB8_CODSER, " + CHR(13) 
       cSql += "       AA5.AA5_PRCCLI  " + CHR(13) 
       cSql += "  FROM " + RetSqlName("AB6") + " AB6, " + CHR(13) 
       cSql += "       " + RetSqlName("AB8") + " AB8, " + CHR(13) 
       cSql += "       " + RetSqlName("AA5") + " AA5, " + CHR(13) 
       cSql += "       " + RetSqlName("SB1") + " SB1  " + CHR(13)
       cSql += " WHERE AB6.AB6_NUMOS  = '" + Alltrim(_cNumOs) + "'" + CHR(13) 
       cSql += " AND AB8.AB8_NUMOS    = AB6.AB6_NUMOS " + CHR(13) 
       cSql += "   AND AB6.AB6_FILIAL = '" + Alltrim(Substr(_Filial,01,02))   + "'" + CHR(13) 
       cSql += "   AND AB8.AB8_FILIAL = AB6.AB6_FILIAL " + CHR(13) 
       cSql += "   AND AB6.D_E_L_E_T_ = '' "             + CHR(13) 
       cSql += "   AND AB8.D_E_L_E_T_ = '' "             + CHR(13) 
       cSql += "   AND AA5.D_E_L_E_T_ = '' "             + CHR(13) 
       cSql += "   AND AB8.AB8_CODSER = AA5.AA5_CODSER " + CHR(13) 
       cSql += "   AND AA5.AA5_FILIAL = ''"              + CHR(13) 
       cSql += "   AND SB1.B1_COD     = AB8.AB8_CODPRO"  + CHR(13)
       cSql += "   AND SB1.D_E_L_E_T_ = '' "             + CHR(13) 

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "PRODUTO", .T., .T. )

       // Imprime os Produtos da Ordem de Serviço
       nProdutos := 0

       PRODUTO->( dbGoTop() )

       _Moeda := PRODUTO->AB6_MOEDA

       WHILE PRODUTO-> ( !EOF() )
          
          If Substr(PRODUTO->AB8_DESPRO,01,03) == "AST"
             PRODUTO->( DbSkip() )
             Loop
          Endif 

          oPrint:Say( _nLin, 0100, PRODUTO->AB8_CODPRO, IIF(nFonte == 1, oFont09, oFont20))

          If Empty(Alltrim(PRODUTO->B1_GDES))
             oPrint:Say( _nLin, 0250, PRODUTO->AB8_DESPRO, IIF(nFonte == 1, oFont09, oFont20))
          Else
             oPrint:Say( _nLin, 0250, PRODUTO->B1_GDES   , IIF(nFonte == 1, oFont09, oFont20))             
          Endif

          oPrint:Say( _nLin, 1050, "UN"               , IIF(nFonte == 1, oFont09, oFont20))
          oPrint:Say( _nLin, 1200, Transform(PRODUTO->AB8_QUANT, "99999")     , IIF(nFonte == 1, oFont09, oFont20))

          // Calcula para Impressão
          _Unitario := PRODUTO->AB8_PRCLIS
          _SubTotal := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS

          // AA5_PRCCLI <> 0 indica que o Cliente paga o Produto
          If PRODUTO->AA5_PRCCLI <> 0
             If PRODUTO->AB8_VUNIT == PRODUTO->AB8_PRCLIS                
                _Desconto := 0
             Else
                _Desconto := (PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS) - (PRODUTO->AB8_QUANT * PRODUTO->AB8_VUNIT)
             Endif
          Else
             _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
          Endif

// Estas linhas foram comentadas em razão de uma alteraçao que provavelmente irá entrar na versão 3.
// Quando a OS for Condição de Pagamento Sem Valor Comercial, não deve ser impresso os totais da os só os unitários
// Quando entrar esta tarefa, comentar as linhas acima e considerar estas abaixo
//          If PRODUTO->AB6_CONPAG == "099"
//             _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
//          Else
//             If PRODUTO->AA5_PRCCLI <> 0
//                If PRODUTO->AB8_VUNIT == PRODUTO->AB8_PRCLIS                
//                   _Desconto := 0
//                Else
//                   _Desconto := (PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS) - (PRODUTO->AB8_QUANT * PRODUTO->AB8_VUNIT)
//                Endif
//             Else
//                _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
//             Endif
//          Endif   
                   
          _Total    := _SubTotal - _Desconto

          If _Moeda == 1
             oPrint:Say( _nLin, 1325, "R$ " + Transform(_Unitario, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1575, "R$ " + Transform(_SubTotal, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1825, "R$ " + Transform(_Desconto, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 2125, "R$ " + Transform(_Total   , "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))                                   
          Else
             oPrint:Say( _nLin, 1325, "U$ " + Transform(_Unitario, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1575, "U$ " + Transform(_SubTotal, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1825, "U$ " + Transform(_Desconto, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 2125, "U$ " + Transform(_Total   , "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))                                   
          Endif

          IF PRODUTO->AA5_PRCCLI == 0
          ELSE
             nProdutos := nProdutos + PRODUTO->AB8_TOTAL
          Endif   
     
// Estas linhas foram comentadas em razão de uma alteraçao que provavelmente irá entrar na versão 3.
// Quando a OS for Condição de Pagamento Sem Valor Comercial, não deve ser impresso os totais da os só os unitários
// Quando entrar esta tarefa, comentar as linhas acima e considerar estas abaixo
//          IF PRODUTO->AA5_PRCCLI == 0
//          ELSE
//             If PRODUTO->AB6_CONPAG == "099"
//                nProdutos := 0
//             Else   
//                nProdutos := nProdutos + PRODUTO->AB8_TOTAL
//             Endif   
//          ENDIF

          _nLin += 50
          
          PRODUTO->( DbSkip() )

       End   

       oPrint:Line( _nLin, 1360, _nLin, 2400 )

       _nLin += 25

       oPrint:Say( _nLin, 1750, "Total dos Produtos:" , IIF(nFonte == 1, oFont09b, oFont20))
 
       If _Moeda == 1
          oPrint:Say( _nLin, 2125, "R$ " + Transform(nProdutos, "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))
       Else
          oPrint:Say( _nLin, 2125, "U$ " + Transform(nProdutos, "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))
       Endif
       
       _nLin += 50

       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 35
       oPrint:Say( _nLin, 1100, "S E R V I Ç O S", IIF(nFonte == 1, oFont10b, oFont20))
       _nLin += 50
       oPrint:Line( _nLin, 0100, _nLin, 2400 )
       _nLin += 35

       // Imprime os Serviços da Ordem de Serviço
       nServicos := 0
   
       PRODUTO->( dbGoTop() )
       
       WHILE PRODUTO-> ( !EOF() )
          
          If Substr(PRODUTO->AB8_DESPRO,01,03) <> "AST"
             PRODUTO->( DbSkip() )
             Loop
          Endif

          oPrint:Say( _nLin, 0100, PRODUTO->AB8_CODPRO, IIF(nFonte == 1, oFont09, oFont20))
          oPrint:Say( _nLin, 0250, PRODUTO->AB8_DESPRO, IIF(nFonte == 1, oFont09, oFont20))
          oPrint:Say( _nLin, 1050, "UN"               , IIF(nFonte == 1, oFont09, oFont20))
          oPrint:Say( _nLin, 1200, Transform(PRODUTO->AB8_QUANT, "99999")     , IIF(nFonte == 1, oFont09, oFont20))

          // Calcula para Impressão
          _Unitario := PRODUTO->AB8_PRCLIS
          _SubTotal := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS

          // AA5_PRCCLI <> 0 indica que o Cliente paga o Produto

          If PRODUTO->AA5_PRCCLI <> 0
             If PRODUTO->AB8_VUNIT == PRODUTO->AB8_PRCLIS                
                _Desconto := 0
             Else
                _Desconto := (PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS) - (PRODUTO->AB8_QUANT * PRODUTO->AB8_VUNIT)
             Endif
          Else
             _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
          Endif
                   
// Estas linhas foram comentadas em razão de uma alteraçao que provavelmente irá entrar na versão 3.
// Quando a OS for Condição de Pagamento Sem Valor Comercial, não deve ser impresso os totais da os só os unitários
// Quando entrar esta tarefa, comentar as linhas acima e considerar estas abaixo
//          If PRODUTO->AB6_CONPAG == "099"
//             _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
//          Else   
//             If PRODUTO->AA5_PRCCLI <> 0
//                If PRODUTO->AB8_VUNIT == PRODUTO->AB8_PRCLIS                
//                   _Desconto := 0
//                Else
//                   _Desconto := (PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS) - (PRODUTO->AB8_QUANT * PRODUTO->AB8_VUNIT)
//                Endif
//             Else
//                _Desconto := PRODUTO->AB8_QUANT * PRODUTO->AB8_PRCLIS
//             Endif
//          Endif   


          _Total    := _SubTotal - _Desconto

          If _Moeda == 1
             oPrint:Say( _nLin, 1325, "R$ " + Transform(_Unitario, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1575, "R$ " + Transform(_SubTotal, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1825, "R$ " + Transform(_Desconto, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 2125, "R$ " + Transform(_Total   , "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))                                   
          Else
             oPrint:Say( _nLin, 1325, "U$ " + Transform(_Unitario, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1575, "U$ " + Transform(_SubTotal, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 1825, "U$ " + Transform(_Desconto, "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))
             oPrint:Say( _nLin, 2125, "U$ " + Transform(_Total   , "9999999.99"), IIF(nFonte == 1, oFont09, oFont20))                                   
          Endif

          IF PRODUTO->AA5_PRCCLI == 0
          ELSE
             If PRODUTO->AB6_CONPAG == "099"
                nServicos := 0
             Else   
                nServicos := nServicos + PRODUTO->AB8_TOTAL
             Endif   
          ENDIF
     
          _nLin += 50
          
          PRODUTO->( DbSkip() )

       End   

       oPrint:Line( _nLin, 1360, _nLin, 2400 )

       _nLin += 25

       oPrint:Say( _nLin, 1750, "Total dos Serviços:" , IIF(nFonte == 1, oFont09b, oFont20))

       IF _Moeda == 1
          oPrint:Say( _nLin, 2125, "R$ " + Transform(nServicos, "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))
       Else
          oPrint:Say( _nLin, 2125, "U$ " + Transform(nServicos, "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))
       Endif             

       _nLin += 50
	
       oPrint:Line( _nLin, 0100, _nLin, 2400 )

       _nLin += 50

       // Imprime os totais da Ordem de Serviço
       oPrint:Say( _nLin, 1750, "Total Ordem de Serviço:" , IIF(nFonte == 1, oFont09b, oFont20))

       IF _Moeda == 1
          oPrint:Say( _nLin, 2125, "R$ " + Transform((nProdutos + nServicos), "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))
       Else
          oPrint:Say( _nLin, 2125, "U$ " + Transform((nProdutos + nServicos), "9999999.99"), IIF(nFonte == 1, oFont09b, oFont20))          
       Endif   

       _nLin += 50
	
       oPrint:Line( _nLin, 0100, _nLin, 2400 )

       _nLin += 50

       // Imprime a Condição de Pagamento da Ordem de Serviço
       oPrint:Say( _nLin, 0100, "Condição de Pagamento:" , IIF(nFonte == 1, oFont09, oFont20))
       oPrint:Say( _nLin, 0500, cCondicao, IIF(nFonte == 1, oFont09b, oFont20))


       // ##################################
       // Imprime a assinatura do cliente ##
       // ##################################
       _nLin += 025

       If File("p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png")
          kAssinatura := "p:\foto_OS\" + cEmpAnt + Substr(_Filial,01,02) + _cNumOs + "A.png"
       Else
          kAssinatura := ""
       Endif

       oPrint:SayBitmap( _nLin, 1600, kAssinatura, 0700, 0200 )

       _nLin += 125
          
	   oPrint:Say( _nLin, 0330, "____________________________________", IIF(nFonte == 1, oFont09b, oFont20))
	   oPrint:Say( _nLin, 1650, "____________________________________", IIF(nFonte == 1, oFont09b, oFont20))
       _nLin += 50
	   oPrint:Say( _nLin, 0330, "Local e Data", IIF(nFonte == 1, oFont09b, oFont20))

       If Empty(Alltrim(kAssinatura))
   	      oPrint:Say( _nLin, 1650, "Assinatura Cliente", IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
   	   Else   
	      oPrint:Say( _nLin, 1650, "Assinatura Cliente (Ass. capturada pelo App)", IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
	      oPrint:Say( _nLin, 1650, "Nome: " + Alltrim(M->AB6_RESPA), IIF(nFonte == 1, oFont09, oFont20))
          _nLin += 50
          oPrint:Say( _nLin, 1650, "Documento: " + Alltrim(M->AB6_NDOCU), IIF(nFonte == 1, oFont09, oFont20))
       Endif       

       PRODUTO->( dbCloseArea() )
      
    Endif

    _nLin := 800

    RESULTADO->( dbCloseArea() )

	oPrint:Preview()
	
	MS_FLUSH()

Return nil

// ############################################
// Função que amplia a assinatura do cliente ##
// ############################################
Static Function AmpliaAssi()

   Local kAssinatura := ""

   Private oDlgAssi

   If File("p:\foto_OS\" + cEmpAnt + M->AB6_FILIAL + M->AB6_NUMOS + "A.png")
      kAssinatura := "p:\foto_OS\" + cEmpAnt + M->AB6_FILIAL + M->AB6_NUMOS + "A.png"   
   Else
      kAssinatura := ""
   Endif

   DEFINE MSDIALOG oDlgAssi TITLE "Impressão Chamado Técnico/Ordem de Serviço" FROM C(178),C(181) TO C(554),C(658) PIXEL

   @ C(002),C(002) Jpeg FILE kAssinatura Size C(232),C(166) PIXEL NOBORDER OF oDlgAssi

   @ C(172),C(100) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgAssi ACTION( oDlgAssi:End() )

   ACTIVATE MSDIALOG oDlgAssi CENTERED 

Return(.T.)
