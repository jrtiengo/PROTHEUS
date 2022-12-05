#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM157.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/02/2013                                                          *
// Objetivo..: Programa que era a impressão do pedido do Call Center pelas ações   *
//             relacionadas.                                                       *
//**********************************************************************************

User Function AUTOM157( _Filial, _Pedido )

   Local OLIST
   Local oOk      := LoadBitmap( GetResources(), "LBOK" )
   Local oNo      := LoadBitmap( GetResources(), "LBNO" )
   LOCAL aLista   := {}
   local aPergs   := {}

   Private cSql   := ""
   Private nLista := 0

   // Pesquisa os atendimentos conforme filtro informado
   If Select("T_ATENDE") > 0
   	  T_ATENDE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.UA_FILIAL , "
   cSql += "       A.UA_NUM    , "
   cSql += "       A.UA_CLIENTE, "
   cSql += "       A.UA_LOJA   , "
   cSql += "       A.UA_CODCONT, "
   cSql += "       A.UA_DESCNT , "
   cSql += "       A.UA_OPERADO, "
   cSql += "       A.UA_CONDPG , "
   cSql += "       A.UA_VEND   , "
   cSql += "       A.UA_EMISSAO, "
   cSql += "       A.UA_CODOBS , "
   cSql += "       A.UA_TRANSP , "
   cSql += "       B.A1_LOJA   , "
   cSql += "       B.A1_NOME   , "
   cSql += "       B.A1_END    , "
   cSql += "       B.A1_BAIRRO , "
   cSql += "       B.A1_MUN    , "
   cSql += "       B.A1_EST    , "
   cSql += "       B.A1_CEP    , "
   cSql += "       B.A1_DDD    , "
   cSql += "       B.A1_TEL    , "
   cSql += "       B.A1_EMAIL  , "
   cSql += "       B.A1_CGC    , "
   cSql += "       C.A3_NOME   , "
   cSql += "       A.UA_NUMSC5 , "
   cSql += "       D.E4_DESCRI , "
   cSql += "       A.UA_TPFRETE, "
   cSql += "       A.UA_DTLIM  , "
   cSql += "       A.UA_MOEDA    "
   cSql += "  FROM " + RetSqlName("SUA010") + " A, "
   cSql += "       " + RetSqlName("SA1010") + " B, "
   cSql += "       " + RetSqlName("SA3010") + " C, "
   cSql += "       " + RetSqlName("SE4010") + " D, "
   cSql += " WHERE A.R_E_C_D_E_L_ = ''          "
   cSql += "   AND A.UA_VEND      = C.A3_COD    "
   cSql += "   AND A.UA_CLIENTE   = B.A1_COD    "
   cSql += "   AND A.UA_LOJA      = B.A1_LOJA   "
   cSql += "   AND A.UA_CONDPG    = D.E4_CODIGO "
   cSql += "   AND A.UA_FILIAL    = '" + Alltrim(_Filial) + "'"
   cSql += "   AND A.UA_NUM       = '" + Alltrim(_Pedido) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDE", .T., .T. )
   
   If T_ATENDE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Carrega o Array aLista
   DbSelectArea("T_ATENDE") 	                  
   T_ATENDE->( DbGoTop() )
   
   While T_ATENDE->(!EOF())

      // Carrega os dados do Cliente
      xFilial  := T_ATENDE->UA_FILIAL
      xAtende  := T_ATENDE->UA_NUM
      xCliente := T_ATENDE->A1_NOME

      If Len(Alltrim(T_ATENDE->A1_CGC)) == 14
         xCgc := Substr(T_ATENDE->A1_CGC,01,02) + "." + ;
                 Substr(T_ATENDE->A1_CGC,03,03) + "." + ;
                 Substr(T_ATENDE->A1_CGC,06,03) + "/" + ;
                 Substr(T_ATENDE->A1_CGC,09,04) + "-" + ;
                 Substr(T_ATENDE->A1_CGC,13,02)
      Else
         xCgc := Substr(T_ATENDE->A1_CGC,01,03) + "." + ;
                 Substr(T_ATENDE->A1_CGC,04,03) + "." + ;
                 Substr(T_ATENDE->A1_CGC,07,03) + "-" + ;
                 Substr(T_ATENDE->A1_CGC,10,02)
      Endif

      xCidade   := T_ATENDE->A1_MUN
      xEstado   := T_ATENDE->A1_EST
      xVendedor := T_ATENDE->A3_NOME 
      xCodigo   := T_ATENDE->UA_CLIENTE
      xLoja     := T_ATENDE->UA_LOJA
      xPedido   := T_ATENDE->UA_NUMSC5
      xEmissao  := Substr(T_ATENDE->UA_EMISSAO,07,02) + "/" + Substr(T_ATENDE->UA_EMISSAO,05,02) + "/" + Substr(T_ATENDE->UA_EMISSAO,01,04)
      xContato  := T_ATENDE->UA_DESCNT
      xNomeCond := T_ATENDE->E4_DESCRI
      xTpFrete  := T_ATENDE->UA_TPFRETE
      xTranspo  := T_ATENDE->UA_TRANSP
      xValidade := T_ATENDE->UA_DTLIM
      xCodObs   := T_ATENDE->UA_CODOBS
      xMoeda    := T_ATENDE->UA_MOEDA
      
      // Carrega o Array aLista com o conteúdo da pesquisa
      AADD(aLista, {.F.      ,; // 01 - Marcação
                    xFilial  ,; // 02 - Nº da Filial
                    xAtende  ,; // 03 - Nº do Atendimento
                    xCgc     ,; // 04 - Nº do CGC/CPF
                    xCliente ,; // 05 - Código do Cliente
                    xCidade  ,; // 06 - Cidade
                    xEstado  ,; // 07 - Estado
                    xVendedor,; // 08 - Nome do Vendedor
                    xCodigo  ,; // 09 - Código do Cliente
                    xLoja    ,; // 10 - Loja do Cliente
                    xPedido  ,; // 11 - Nº do Pedido de Venda
                    xEmissao ,; // 12 - Data de Emissão             
                    xContato ,; // 13 - Nome do Contato do Cliente
                    xNomeCond,; // 14 - Nome da Condição de Pagamento
                    xTpFrete ,; // 15 - Tipo de Frete 
                    xTranspo ,; // 16 - Código da Transportadora
                    xValidade,; // 17 - Data de Validade do Atendimento
                    xCodObs  ,; // 18 - Código da Chave da Observação (SYP) 
                    xMoeda})    // 19 - Moeda do Pedido

      T_ATENDE->( DbSkip() )
       
   Enddo                            

   // Verifica se o Array está carregado
   If Len(aLista) == 0
      MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não existem dados a serem visualizados para este filtro.")
	  T_ATENDE->(DBCLOSEAREA())
  	  RETURN()
   ENDIF

   // Mostra o resultado
   DEFINE MSDIALOG _oDlg TITLE "Atendimentos Call Center" FROM (180),(210) TO (700),(1320) PIXEL

   // Cria Componentes Padroes do Sistema
   @ 10,05 LISTBOX oList FIELDS HEADER "", "FL" ,"Nº Atend.", "Nº PV", "CGC/CPF", "Cliente", "Cidade", "UF", "Vendedor" PIXEL SIZE 550,230 OF _oDlg ;
           ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aLista )
   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
         	        	       aLista[oList:nAt,03],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,04],;
         	        	       aLista[oList:nAt,05],;
         	        	       aLista[oList:nAt,06],;
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08]}}
         	        	                	        	        
   DEFINE SBUTTON BUTON1 FROM C(190), C(190) TYPE 06 OF _oDlg ENABLE ACTION( I_ATENDIMENTO(aLista) )
   DEFINE SBUTTON BUTON1 FROM C(190), C(220) TYPE 20 OF _oDlg ENABLE ACTION _oDlg:End()
     
   ACTIVATE MSDIALOG _oDlg CENTERED 

   T_ATENDE->(DBCLOSEAREA())

   // Limpa as variáveis de filtro
   cCliente      := Space(06)
   cLoja         := Space(03)
   cVendedor     := Space(06)
   cAtendimento  := Space(06)  
   cNomeCliente  := Space(60)
   cNomeVendedor := Space(60)

   nGet1	     := Space(06)
   nGet2	     := Space(03)
   nGet3         := Space(06)
   nGet4         := Space(06)

Return .T.

// Funcção que gera a impressão do Atendimento do Call Cente
Static Function I_ATENDIMENTO(aLista)

	Local cQuery       := ""
	Local aStru        := {}
	Local _cPedAtu     := ""
	Local _lPrimeiro   := .T.
    Local cSql         := ""
    Local nContador    := 0
    Local xLinhas      := 0
    Local cTexto1 	   := ""
    Local cTexto2      := ""
    Local dData        := ""
    Local cComentario  := ""
    Local nProdutos    := 0
    Local nServicos    := 0
    Local cCondicao    := ""
    Local nFonte       := 0
    Local lExiste      := .F.
    Local cCodigos     := ""
    Local cNomeTransp  := ""
    Local cAtendimento := ""
    Local nAdicional   := 10
    Local cEntresi     := ""
    Local cDescricao   := ""

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
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont25, oFont25b, oFont30

    // Verifica se houve a marcação de pelo menos um atendimento para impressão
    lExiste  := .F.    
    cCodigos := ""
    cEntresi := ""
    For nContar = 1 to Len(aLista)
        If aLista[nContar,1] == .T.
           If !Empty(cEntresi)
              If cEntresi <> Alltrim(aLista[nContar,3])
                 MsgAlert("Atenção !!" + chr(13) + chr(13) + "Indique somente um Atendimento para Impressão de cada vez.")
                 Return .T.
              Endif
           Endif   
           lExiste  := .T.
           cCodigos := cCodigos + "'" + Alltrim(aLista[nContar,3]) + "',"
           cEntresi := Alltrim(aLista[nContar,3])
        Endif
    Next nContar       

    If lExiste == .F.
       MsgAlert("Atenção !!" + chr(13) + chr(13) + "Não foi indicado nenhum Atendimento para impressão." + chr(13) + chr(13) + "Verifique !")
       Return .T.
    Endif

    // Posiciona no primeiro Atendimengto para capturar os dados a serem impressos
    For nContar = 1 to Len(aLista)
        If aLista[nContar,1] == .T.
           Exit
        Endif
    Next nContar    

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()
	
	// Orientação da página
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato
	
	// Tamanho da página na impressão
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4
	
	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
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
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )	

	// Pesquisa o nome da Empresa/Filial para o cabecalho
	SM0->( DbSeek( cEmpAnt + cFilAnt ) )

    cAtendimento := aLista[nContar,2]

    // Início do relatório
    oPrint:StartPage()

    _nLin := 0060

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50
	
    // Logotipo e identificação do pedido
    oPrint:SayBitmap( _nLin, 0110, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont12b  )
    _nLin := _nLin + 70
    oPrint:Say( _nLin, 1000, "Matriz:", oFont08  )    
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1110 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0001-61    Insc. Estadual: 096/27777447", oFont08  )    
    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA SÃO JOSÉ, 1767 - CEP: 95.020-270 - CAXIAS DO SUL - RS Fone: (54)32272333", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0002-42    Insc. Estadual: 029/0448913", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA GENERAL NETO, 618 - CEP: 96.015-250 - PELOTAS - RS Fone: (53)30262802", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 0110, "www.automatech.com.br", oFont10  )
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0004-04    Insc. Estadual: 093/0410289", oFont08  )    

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50
   
    oPrint:Say( _nLin - 20, 0110, "Nº Atendimento: " + Alltrim(aLista[nContar,03]), oFont12b)
    oPrint:Say( _nLin - 20, 1000, "Nº Pedido: "      + Alltrim(aLista[nContar,11]), oFont12b)
    oPrint:Say( _nLin - 20, 1750, "Emissão: "        + Alltrim(aLista[nContar,12]), oFont12b)

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 30
    
    // Dados do Cliente
    If Select("T_CLIENTE") > 0
       T_CLIENTE->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A1_COD ,   "
    cSql += "       A1_LOJA,   "
    cSql += "       A1_NOME,   "
    cSql += "       A1_END ,   "
    cSql += "       A1_BAIRRO, "
    cSql += "       A1_EMAIL,  "
    cSql += "       A1_CGC,    "
    cSql += "       A1_INSCR,  "
    cSql += "       A1_DDD,    "
    cSql += "       A1_TEL,    "
    cSql += "       A1_FAX,    "
    cSql += "       A1_MUN,    "
    cSql += "       A1_CEP,    "
    cSql += "       A1_EST     " 
    cSql += "  FROM " + RetSqlName("SA1010")
    cSql += " WHERE A1_COD  = '" + aLista[nContar,09] + "'"
    cSql += "   AND A1_LOJA = '" + aLista[nContar,10] + "'"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
    
    oPrint:Say( _nLin, 0110, "Cliente:" , oFont10)
    oPrint:Say( _nLin, 0400, "["+ T_CLIENTE->A1_COD +"] "+ T_CLIENTE->A1_NOME, oFont10b)
    oPrint:Say( _nLin, 1500, "Fone/Fax:", oFont10)
    oPrint:Say( _nLin, 1730, Transform( AllTrim( T_CLIENTE->A1_DDD ) + T_CLIENTE->A1_TEL, "@R (99) 9999-9999" )+"/"+Transform( AllTrim( T_CLIENTE->A1_DDD ) + T_CLIENTE->A1_FAX, "@R (99) 9999-9999" ), oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Endereço:", oFont10)
    oPrint:Say( _nLin, 0400, AllTrim( T_CLIENTE->A1_END ) +" "+ AllTrim( T_CLIENTE->A1_BAIRRO ), oFont10b)
    oPrint:Say( _nLin, 1500, "Cidade:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(T_CLIENTE->A1_MUN) + " - " + Transform( AllTrim(T_CLIENTE->A1_CEP ), "@R 99999-999"), oFont10b)

    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "E-mail:"  , oFont10)
    oPrint:Say( _nLin, 0400, AllTrim( T_CLIENTE->A1_EMAIL ), oFont10b)
    oPrint:Say( _nLin, 1500, "Estado:"  , oFont10)
    oPrint:Say( _nLin, 1730, T_CLIENTE->A1_EST, oFont10b)

    _nLin := _nLin + 50
        
    oPrint:Say( _nLin, 0110, "CNPJ/CPF:", oFont10)
    If Len(AllTrim(T_CLIENTE->A1_CGC)) == 14
       oPrint:Say( _nLin, 0400, Substr(T_CLIENTE->A1_CGC,01,02) + "." + Substr(T_CLIENTE->A1_CGC,03,03) + "." + Substr(T_CLIENTE->A1_CGC,06,03) + "/" + Substr(T_CLIENTE->A1_CGC,09,04) + "-" + Substr(T_CLIENTE->A1_CGC,13,02), oFont10b)
    Else
       oPrint:Say( _nLin, 0400, Substr(T_CLIENTE->A1_CGC,01,03) + "." + Substr(T_CLIENTE->A1_CGC,04,03) + "." + Substr(T_CLIENTE->A1_CGC,07,03) + "-" + Substr(T_CLIENTE->A1_CGC,10,02), oFont10b)       
    Endif

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "I.E.:"    , oFont10)    
    oPrint:Say( _nLin, 0400, AllTrim( T_CLIENTE->A1_INSCR ), oFont10b)    

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
            
    oPrint:Say( _nLin - 20, 0110, "Conforme combinado, apresentamos abaixo a proposta para fornecimento de equipamentos e serviços:"    , oFont10b)        

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 30    

    T_CLIENTE->( dbCloseArea() )

    // Pesquisa o nome da transportadora para impressão
    If Select("T_TRANSPORTE") > 0
       T_TRANSPORTE->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A4_COD , "
    cSql += "       A4_NOME  "
    cSql += "  FROM " + RetSqlName("SA4010")
    cSql += " WHERE A4_COD  = '" + aLista[nContar,16] + "'"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTE", .T., .T. )

    If !T_TRANSPORTE->( EOF() )
       cNomeTranspo := Alltrim(T_TRANSPORTE->A4_NOME)
    Else
       cNomeTranspo := ""
    Endif

    T_TRANSPORTE->( dbCloseArea() )

    oPrint:Say( _nLin, 0110, "Contato:"        , oFont10)
    oPrint:Say( _nLin, 0400, aLista[nContar,13], oFont10b)    
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Vendedor:"       , oFont10)
    oPrint:Say( _nLin, 0400, aLista[nContar,08], oFont10b)    
    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "Condição Pgtº:"  , oFont10)
    oPrint:Say( _nLin, 0400, aLista[nContar,14], oFont10b)    
    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "Transportadora:" , oFont10)
    oPrint:Say( _nLin, 0400, cNomeTranspo      , oFont10b)    
    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "Frete:"          , oFont10)
    oPrint:Say( _nLin, 0400, If(aLista[nContar,15] == "C", "C I F", "F O B"), oFont10b)    
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Validade:            " + Substr(aLista[nContar,17],07,02) + "/" + Substr(aLista[nContar,17],05,02) + "/" + Substr(aLista[nContar,17],01,04), oFont10b)
    _nLin := _nLin + 50

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
    oPrint:Say(  _nLin - 20, 1000, "P R O D U T O S"  , oFont12b)

    If aLista[nContar,19] == 1
       oPrint:Say(  _nLin - 20, 2010, "Moeda: R$", oFont12b)
    Else
       oPrint:Say(  _nLin - 20, 2010, "Moeda: U$", oFont12b)       
    Endif   
    
    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    nPosicao := _nLin
    
    _nLin := _nLin + 50

    oPrint:Say( _nLin - 20, 0110, "Código"   , oFont25b)
    oPrint:Say( _nLin - 20, 0555, "Descrição", oFont25b)
    oPrint:Say( _nLin - 20, 1500, "UM"       , oFont25b)
    oPrint:Say( _nLin - 20, 1750, "Qtd"      , oFont25b)
    oPrint:Say( _nLin - 20, 1930, "Unitário" , oFont25b)
    oPrint:Say( _nLin - 20, 2210, "Total"    , oFont25b)

    _nLin := _nLin + 50
                        
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Pesquisa os Produtos a serem impressos do atendimento
    If Select("T_PRODUTOS") > 0
       T_PRODUTOS->( dbCloseArea() )
    EndIf

    cSql := ""    
    cSql := "SELECT A.UB_PRODUTO, "
    cSql += "       B.B1_DESC   , "
    cSql += "       B.B1_DAUX   , "
    cSql += "       B.B1_TIPO   , "
    cSql += "       B.B1_POSIPI , "
    cSql += "       B.B1_UM     , "
    cSql += "       A.UB_QUANT  , "
    cSql += "       A.UB_VRUNIT , "
    cSql += "       A.UB_VLRITEM  "
    cSql += "  FROM " + RetSqlName("SUB010") + " A, "
    cSql += "       " + RetSqlName("SB1010") + " B  "
    cSql += " WHERE A.UB_NUM     = '" + Alltrim(aLista[nContar,3]) + "'"
    cSql += "   AND A.UB_FILIAL  = '" + Alltrim(aLista[nContar,2]) + "'"
    cSql += "   AND A.UB_PRODUTO = B.B1_COD "
    cSql += "   AND A.R_E_C_D_E_L_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

    nSomaPro    := 0
    nSomaSer    := 0
    nSomaFre    := 0
    cClassifica := ""

    While T_PRODUTOS->(!EOF())    

        oPrint:Say( _nLin, 0110, Substr(T_PRODUTOS->UB_PRODUTO,01,20), oFont25)

        cDescricao := ALLTRIM(T_PRODUTOS->B1_DESC) + " " + ALLTRIM(T_PRODUTOS->B1_DAUX)

        If Len(cDescricao) > 55
           oPrint:Say( _nLin, 0555, Substr(cDescricao,01,55), oFont30)        
        Else
           oPrint:Say( _nLin, 0555, cDescricao, oFont30)                
        Endif

        oPrint:Say( _nLin, 1500, T_PRODUTOS->B1_UM                   , oFont25)            
        oPrint:Say( _nLin, 1650, STR(T_PRODUTOS->UB_QUANT,10,02)     , oFont25)            
        oPrint:Say( _nLin, 1890, STR(T_PRODUTOS->UB_VRUNIT,10,02)    , oFont25)            
        oPrint:Say( _nLin, 2120, STR(T_PRODUTOS->UB_VLRITEM,10,02)   , oFont25)            

        If Alltrim(T_PRODUTOS->B1_TIPO) == "MO"
           nSomaSer := nSomaSer + T_PRODUTOS->UB_VLRITEM
        Else   
           nSomaPro := nSomaPro + T_PRODUTOS->UB_VLRITEM
        Endif                                                                

        If !Empty(T_PRODUTOS->B1_POSIPI)
           cClassifica := cClassifica + Alltrim(T_PRODUTOS->UB_PRODUTO)     + "/" + ;
                                        Substr(T_PRODUTOS->B1_POSIPI,01,04) + "." + ;
                                        Substr(T_PRODUTOS->B1_POSIPI,05,02) + "." + ;
                                        Substr(T_PRODUTOS->B1_POSIPI,07,02) + " - "
        Endif

        _nLin := _nLin + 50

        If Len(cDescricao) > 55
           _nLin := _nLin + 10
           oPrint:Say( _nLin, 0555, Substr(cDescricao,56,55), oFont30)        
           _nLin := _nLin + 50
        Endif

        T_PRODUTOS->( DbSkip() )
        
    Enddo        

    // Prepara a variável cClassifica para impressão
    If Len(cClassifica) < 320
       cClassifica := cClassifica + Space(320 - Len(cClassifica))
    Endif

    T_PRODUTOS->( dbCloseArea() )

    oPrint:Line( nPosicao, 0100, _nLin, 0100 )
    oPrint:Line( nPosicao, 0548, _nLin, 0548 )
    oPrint:Line( nPosicao, 1490, _nLin, 1490 )
    oPrint:Line( nPosicao, 1560, _nLin, 1560 )
    oPrint:Line( nPosicao, 1860, _nLin, 1860 )
    oPrint:Line( nPosicao, 2100, _nLin, 2100 )
    oPrint:Line( nPosicao, 2330, _nLin, 2330 )
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    nPosicao2 := _nLin 

    _nLin := _nLin + 30

    oPrint:Say( _nLin, 0110, "[ Código Produto / NCM ]", oFont10b)    
    oPrint:Say( _nLin, 1700, "Total dos Produtos" , oFont25b)    
    oPrint:Say( _nLin, 2120, STR(nSomaPro,10,02)  , oFont25b)

    _nLin := _nLin + 50
    oPrint:Say( _nLin, 1700, "Total dos Serviços"       , oFont25b)    
    oPrint:Say( _nLin, 0110, Substr(cClassifica,001,080), oFont25)    
    oPrint:Say( _nLin, 2120, STR(nSomaSer,10,02)        , oFont25b)

    _nLin := _nLin + 50
    oPrint:Say( _nLin, 1700, "Total do  Frete"          , oFont25b)    
    oPrint:Say( _nLin, 0110, Substr(cClassifica,081,080), oFont25)    
    oPrint:Say( _nLin, 2120, STR(nSomaFre,10,02)        , oFont25b)

    _nLin := _nLin + 50
    oPrint:Say( _nLin, 1700, "Total do Pedido"          , oFont25b)    
    oPrint:Say( _nLin, 0110, Substr(cClassifica,161,080), oFont25)    
    oPrint:Say( _nLin, 2120, STR((nSomaPro + nSomaSer + nSomaFre),10,02)   , oFont25b)
   
    _nLin := _nLin + 50
   
    oPrint:Say( _nLin, 0110, Substr(cClassifica,241,080), oFont25)    
    
    _nLin := _nLin + 050
    
    oPrint:Line( nPosicao, 0100, _nLin, 0100 )
    oPrint:Line( nPosicao, 2330, _nLin, 2330 )
    oPrint:Line( nPosicao, 2100, _nLin, 2100 )

    oPrint:Line( nPosicao2, 1690, _nLin, 1690 )
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    nPosicao3 := _nLin

    _nLin := _nLin + 50

    // Imprime as Observações do Pedido
    oPrint:Say( _nLin, 0110, "OBSERVAÇÕES", oFont10b)    
    
    _nLin := _nLin + 70

    // Pesquisa os Produtos a serem impressos do atendimento
    If Select("T_NOTA") > 0
       T_NOTA->( dbCloseArea() )
    EndIf

    cSql := ""    
    cSql := "SELECT YP_TEXTO "
    cSql += "  FROM " + RetSqlName("SYP010")
    cSql += " WHERE YP_CHAVE = '" + Alltrim(aLista[nContar,18]) + "'"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

    // Prepara a observação para impressão
    X := 0

    For x = 1 to 20
        j := Strzero(x,2)
        cNota&j := ""
    Next x
    
    X := 1

    While T_NOTA->(!EOF())    
        
       J := Strzero(x,2)
       
       cNota&j := StrTran(T_NOTA->YP_TEXTO, "\13\10", "")
       
       T_NOTA->( DbSkip() )
       
       x := x + 1
       
    Enddo
        
    T_NOTA->( dbCloseArea() )        
    
    oPrint:Say( _nLin, 0110, Alltrim(cNota01) + " " + Alltrim(cNota02), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota03) + " " + Alltrim(cNota04), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota05) + " " + Alltrim(cNota06), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota07) + " " + Alltrim(cNota08), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota09) + " " + Alltrim(cNota10), oFont10b)                
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota11) + " " + Alltrim(cNota12), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota13) + " " + Alltrim(cNota14), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota15) + " " + Alltrim(cNota16), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota17) + " " + Alltrim(cNota18), oFont10b)    
    _nLin := _nLin + 50
    oPrint:Say( _nLin, 0110, Alltrim(cNota19) + " " + Alltrim(cNota20), oFont10b)    
    _nLin := _nLin + 50

    oPrint:Line( 060  , 0100, _nLin, 0100 )
    oPrint:Line( 060  , 2330, _nLin, 2330 )
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 30

    oPrint:Say( _nLin, 0110, "Os valores cotados em dólar serão convertidos em real de acordo com a taxa do dólar comercial (PTAX venda) do dia do faturamento.", oFont09b)

    _nLin := _nLin + 100

    oPrint:Say( _nLin, 0110, "Sem mais para o momento nos colocamos à disposição para auxiliá-los no que for preciso.", oFont09b)

    _nLin := _nLin + 100

    oPrint:Say( _nLin, 0110, "Atenciosamente", oFont09b)    
    oPrint:Line( _nLin, 1800, _nLin, 2300 )
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, aLista[nContar,08], oFont09b)    
    oPrint:Say( _nLin, 1900, "Aceite do Cliente", oFont09b)    
    _nLin := _nLin + 100

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    oPrint:Line( 0210, 0100, _nLin, 0100 )
    oPrint:Line( 0210, 2330, _nLin, 2330 )

    _nLin := _nLin + 050
    oPrint:Say( _nLin, 0110, "AUTOMR07.PRW", oFont06)        

	oPrint:Preview()
	
	MS_FLUSH()

    // Limpa a marcação da ordem de produção impressa
    For nContar = 1 to Len(aLista)
        aLista[nContar,1] := .F.
    Next nContar    

   // Limpa as variáveis de filtro
   cCliente      := Space(06)
   cLoja         := Space(03)
   cVendedor     := Space(06)
   cAtendimento  := Space(06)  
   cNomeCliente  := Space(60)
   cNomeVendedor := Space(60)

   nGet1	     := Space(06)
   nGet2	     := Space(03)
   nGet3         := Space(06)
   nGet4         := Space(06)

Return nil