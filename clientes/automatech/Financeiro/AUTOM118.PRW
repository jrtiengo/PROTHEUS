#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM118.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 25/06/2012                                                          ##
// Objetivo..: Este programa tem por finalidade de emitir recibos de recebimentos  ##
//             e pagamentos avulsos.                                               ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: Sem Retorno                                                         ##
// ##################################################################################

User Function AUTOM118()

   Local lChumba    := .F.

   Private cCliCod  := Space(06)
   Private cCliLoj  := Space(03)
   Private cNomCli  := Space(60)
   Private cForCod  := Space(06)
   Private cForLoj  := Space(03)
   Private cNomFor  := Space(60)
   Private cTexto1  := Space(100)
   Private cTexto2  := Space(100)
   Private cTexto3  := Space(100)
   Private cTexto4  := Space(100)
   Private cTexto5  := Space(100)
   Private cValor   := 0
   Private cEmissao := Date()
   Private aTipo    := {"01 - A Receber", "02 - A Pagar"}

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
   Private cComboBx1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Emissão de Recibo Avulso" FROM C(178),C(181) TO C(388),C(771) PIXEL

   @ C(006),C(008) Say "Tipo de Recibo"                   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(022),C(007) Say "Cliente"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(007) Say "Fornecedor"                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(007) Say "Valor"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(068),C(007) Say "Emissão"                          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(095) Say "Proveniente de/para pagamento de" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(004),C(049) ComboBox cComboBx1 Items aTipo Size C(072),C(010) PIXEL OF oDlg
   @ C(021),C(040) MsGet oGet1  Var cCliCod    When Substr(cComboBx1,01,02) == "01" Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(021),C(074) MsGet oGet2  Var cCliLoj    When Substr(cComboBx1,01,02) == "01" Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TRAZCLIE() )
   @ C(021),C(095) MsGet oGet3  Var cNomCli    When lChumba                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(034),C(040) MsGet oGet4  Var cForCod    When Substr(cComboBx1,01,02) == "02" Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA2")
   @ C(034),C(074) MsGet oGet5  Var cForLoj    When Substr(cComboBx1,01,02) == "02" Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TRAZFORNE() )
   @ C(034),C(095) MsGet oGet6  Var cNomFor    When lChumba                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(054),C(040) MsGet oGet7  Var cValor                                          Size C(052),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlg
   @ C(067),C(040) MsGet oGet8  Var cEmissao                                        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(054),C(095) MsGet oGet9  Var cTexto1                                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(063),C(095) MsGet oGet10 Var cTexto2                                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(095) MsGet oGet11 Var cTexto3                                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(081),C(095) MsGet oGet12 Var cTexto4                                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(090),C(095) MsGet oGet13 Var cTexto5                                         Size C(194),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(086),C(010) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPRECIBO() )
   @ C(086),C(049) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o cliente informado
Static Function TRAZCLIE()

   Local cSql := ""
   
   If Empty(Alltrim(cClicod))
      Return .T.
   Endif
   
   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_NOME  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(cCliCod) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(cCliLoj) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      cCliCod := Space(06)
      cCliLoj := Space(03)
      cNomCli := ""
   Else
      cNomCli := T_CLIENTE->A1_NOME
   Endif
   
Return .T.

// Função que pesquisa o fornecedor informado
Static Function TRAZFORNE()

   Local cSql := ""
   
   If Empty(Alltrim(cForCod))
      Return .T.
   Endif
   
   If Select("T_FORNECE") > 0
   	  T_FORNECE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD , "
   cSql += "       A2_NOME  "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD  = '" + Alltrim(cForCod) + "'"
   cSql += "   AND A2_LOJA = '" + Alltrim(cForLoj) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECE", .T., .T. )

   If T_FORNECE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      cForCod := Space(06)
      cForLoj := Space(03)
      cNomFor := ""
   Else
      cNomFor := T_FORNECE->A2_NOME
   Endif
   
Return .T.

// Função que pesquisa o fornecedor informado
Static Function IMPRECIBO()

   Local cExtenso  
   Local cDesc1   := ""
   Local cDesc2   := ""
   Local cDesc3   := ""
   Local cPict    := ""
   Local titulo   := "Recibo Avulso"
   Local nLin     := 80
   Local cSql     := ""
   Local Cabec1   := ""
   Local Cabec2   := ""
   Local imprime  := .T.
   Local aOrd     := {}
   Local _Filial  := ""
   Local cCaminho := ""

   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private limite      := 80
   Private tamanho     := "P"
   Private nomeprog    := "Poder de/em Terceiros"
   Private nTipo       := 18
   Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey    := 0
   Private cPerg       := "VENDA"
   Private cbtxt       := Space(10)
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag       := 01
   Private wnrel       := "Demonstrações"
   Private cString     := "SC5"

   // Consiste os dados antes da impressão
   If Int(Val(cCliCod)) + Int(Val(cForCod)) == 0
      Msgalert("Necessário informar o Cliente ou Fornecedor.")
      Return .T.
   Endif

   If Substr(cComboBx1,01,02) == "01"
      If Int(Val(cCliCod)) == 0
         Msgalert("Necessário informar o Cliente.")
         Return .T.
      Endif
   Else
      If Int(Val(cForCod)) == 0   
         Msgalert("Necessário informar o Fornecedor.")
         Return .T.
      Endif
   Endif
      
   If cValor == 0
      Msgalert("Valor do recibo não informado.")
      Return .T.
   Endif

   If Empty(cEmissao)
      Msgalert("Data de Emissão não informada.")
      Return .T.
   Endif

   Processa( {|| IDEMONSTRACAO(Cabec1,Cabec2,Titulo,nLin) }, "Aguarde...", "Imprimindo Recibo",.F.)

Return .T.

// Função que imprime o recibo
Static Function IDEMONSTRACAO(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21, oFont22, oFont23  
   Private nLimvert   := 3500
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0
   Private aTempo     := {}

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetPortrait()    // Para Retrato
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont23   := TFont():New( "Arial",,16,,.f.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont22   := TFont():New( "Arial",,20,,.f.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Imprime o recibo
   nPagina  := 0
   _nLin    := 10
      
   // Logotipo e identificação do pedido
   oPrint:SayBitmap( _nLin, 0010, "logoautoma.bmp", 0700, 0200 )
   _nLin := _nLin + 100
   oPrint:Say( _nLin, 00750, "A TECNOLOGIA COMO ALIADA PARA GERAR RESULTADO.", oFont16b  )
   _nLin := _nLin + 300
   oPrint:Say( _nLin, 0900, "R E C I B O - R$ " + transform(cValor,"@E 999,999,999.99"), oFont20b  )
   _nLin := _nLin + 300

   Do Case
      Case cEmpAnt == "01"

           Do Case
              Case cFilAnt == "01"
                   kCidade := "Porto Alegre"
                   oPrint:Say( _nLin, 0150, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont16b  )
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Endereço: Rua Dr. João Inácio, 1110.", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CEP: 90.230-181 - Porto Alegre/RS", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Telefone: (51) 3017-8300", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CNPJ: 03.385.913/0001-61                   Insc. Estadual: 096/2777447", oFont23  )   

              Case cFilAnt == "02"
                   kCidade := "Caxias do Sul"
                   oPrint:Say( _nLin, 0150, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont16b  )
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Endereço: Rua São José, 1767", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CEP: 95.020-270 - Caxias do Sul/RS", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Telefone: (54) 3227-2333", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CNPJ: 03.385.913/0002-42                   Insc. Estadual: 029/0448913", oFont23  )   

              Case cFilAnt == "05"
                   kCidade := "São Paulo"
                   oPrint:Say( _nLin, 0150, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont16b  )
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Endereço: Rua Conselheiro Moreira de Barros, 1721", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CEP: 02.430-000 - São Paulo/SP", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Telefone: (11) 3140-02040", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CNPJ: 03.385.913/0006-76                   Insc. Estadual: 141977551117", oFont23  )   

              Case cFilAnt == "06"
                   kCidade := "Cariacica"
                   oPrint:Say( _nLin, 0150, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont16b  )
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Endereço: Rod. Governado Mário Covas 2101 KM 282", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CEP: 29.157-100 - Cariacica/ES", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Telefone: (27) 3331-5000", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CNPJ: 03.385.913/0007-57                   Insc. Estadual: 083.319.06-9", oFont23  )   

              Case cFilAnt == "07"
                   kCidade := "Porto Alegre"
                   oPrint:Say( _nLin, 0150, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont16b  )
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Endereço: Rua Dr. João Inácio, 1116.", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CEP: 90.230-181 - Porto Alegre/RS", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "Telefone: (51) 3017-8300", oFont23  )   
                   _nLin := _nLin + 70
                   oPrint:Say( _nLin, 0150, "CNPJ: **.***.***/****-**                   Insc. Estadual: ***/*******", oFont23  )   

           EndCase

      Case cEmpAnt == "02"
           kCidade := "Curitiba"
           oPrint:Say( _nLin, 0150, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont16b  )
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Endereço: Rua Ten. Francisco Ferreira de Souza, 1052 01", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CEP: 81.630-010 - Curitiba/PR", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Telefone: (41) 3024-6675", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CNPJ: 12.757.071/0001-12                   Insc. Estadual: 9053742146", oFont23  )   

      Case cEmpAnt == "03"
           kCidade := "Porto Alegre"
           oPrint:Say( _nLin, 0150, "ATECH SERVIÇOS DE AUTOMAÇÃO LTDA", oFont16b  )
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Endereço: Rua Dr. João Inácio, 1162", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CEP: 90.230-181 - Porto Alegre/RS", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Telefone: (51) 3017-8300", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CNPJ: 07.166.377/0001-64                   Insc. Estadual: 096/3692399", oFont23  )   

      Case cEmpAnt == "04"
           kCidade := "Pelotas"
           oPrint:Say( _nLin, 0150, "ATECHPEL AUTOMAÇÃO E SERVIÇOS LTDA", oFont16b  )
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Endereço: Rua Marcilio Dias, 1393", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CEP: 96.020-480 - Pelotas/RS", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "Telefone: (53) 3026-2802", oFont23  )   
           _nLin := _nLin + 70
           oPrint:Say( _nLin, 0150, "CNPJ: 27.379.584/0001-04                   Insc. Estadual: 093/0465890", oFont23  )   

   EndCase

   _nLin := _nLin + 200   

   // Imprime os dados do Cliente/Fornecedor
   If Select("T_RECIBO") > 0
   	  T_RECIBO->( dbCloseArea() )
   EndIf

   If Substr(cComboBx1,01,02) == "01"   
      cSql := ""
      cSql := "SELECT A1_NOME  AS NOME     , "
      cSql += "       A1_END   AS ENDERECO , "
      cSql += "       A1_CEP   AS CEP      , "
      cSql += "       A1_MUN   AS CIDADE   , "
      cSql += "       A1_CGC   AS CNPJ     , "
      cSql += "       A1_INSCR AS INSCRICAO, "
      cSql += "       A1_DDD   AS DDD      , "
      cSql += "       A1_TEL   AS TELEFONE   "
      cSql += "  FROM " + RetSqlName("SA1")
      cSql += " WHERE A1_COD  = '" + Alltrim(cCliCod) + "'"
      cSql += "   AND A1_LOJA = '" + Alltrim(cCliLoj) + "'"
   Else
      cSql := ""
      cSql := "SELECT A2_NOME  AS NOME     , "
      cSql += "       A2_END   AS ENDERECO , "
      cSql += "       A2_CEP   AS CEP      , "
      cSql += "       A2_MUN   AS CIDADE   , "
      cSql += "       A2_CGC   AS CNPJ     , "
      cSql += "       A2_INSCR AS INSCRICAO, "
      cSql += "       A2_DDD   AS DDD      , "
      cSql += "       A2_TEL   AS TELEFONE   "
      cSql += "  FROM " + RetSqlName("SA2")
      cSql += " WHERE A2_COD  = '" + Alltrim(cForCod) + "'"
      cSql += "   AND A2_LOJA = '" + Alltrim(cForLoj) + "'"
   Endif      

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECIBO", .T., .T. )
   
   If Substr(cComboBx1,01,02) == "01"   
      oPrint:Say( _nLin, 0150, "Recebemos de:", oFont23  )
   Else   
      oPrint:Say( _nLin, 0150, "Pagamos a:"   , oFont23  )      
   Endif

   _nLin := _nLin + 100

   oPrint:Say( _nLin, 0150, Alltrim(T_RECIBO->NOME), oFont16b  )      
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, "Endereço: " + Alltrim(T_RECIBO->ENDERECO), oFont23  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, "CEP: " + Substr(T_RECIBO->CEP,01,02) + "." + Substr(T_RECIBO->CEP,03,03) + "-" + Substr(T_RECIBO->CEP,06,03) + "   -    " + Alltrim(T_RECIBO->CIDADE), oFont23  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, "Telefone: (" + Alltrim(T_RECIBO->DDD) + ") " + Alltrim(T_RECIBO->TELEFONE), oFont23  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, Substr(T_RECIBO->CNPJ,01,02) + "." + Substr(T_RECIBO->CNPJ,03,03) + "." + Substr(T_RECIBO->CNPJ,06,03) + "/" + Substr(T_RECIBO->CNPJ,09,04) + "." + Substr(T_RECIBO->CNPJ,13,02) + "                   Insc. Estadual: " + Alltrim(T_RECIBO->INSCRICAO), oFont23  )   
   _nLin := _nLin + 200   

   oPrint:Say( _nLin, 0150, "A importância de R$ " + transform(cValor,"@E 999,999,999.99"), oFont23  )
   _nLin := _nLin + 100
   
   cExtenso := PADR(Extenso(cValor),100,"*")

   If Len(Alltrim(cExtenso)) <= 100   
      oPrint:Say( _nLin, 0150, cExtenso, oFont12  )
   Else
      oPrint:Say( _nLin, 0150, Substr(cExtenso,01,100), oFont12  )      
      _nLin := _nLin + 70      
      oPrint:Say( _nLin, 0150, Substr(cExtenso,101), oFont12  )      
   Endif

   _nLin := _nLin + 100
   oPrint:Say( _nLin, 0150, "Referente", oFont23  )   

   _nLin := _nLin + 100
   oPrint:Say( _nLin, 0150, cTexto1, oFont12  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, cTexto2, oFont12  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, cTexto3, oFont12  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, cTexto4, oFont12  )   
   _nLin := _nLin + 70
   oPrint:Say( _nLin, 0150, cTexto5, oFont12  )   

   _nLin := _nLin + 200
   
   Do Case
      Case Month(cEmissao) = 1   
           oPrint:Say( _nLin, 0150, kCidade + ", " + strzero(day(cEmissao),2) + " de Janeiro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 2   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Fevereiro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 3   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Março de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 4   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Abril de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 5   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Maio de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 6   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Junho de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 7   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Julho de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 8   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Agosto de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 9   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Setembro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 10   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Outubro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 11   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Novembro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
      Case Month(cEmissao) = 12   
           oPrint:Say( _nLin, 0150, kCidade + ", "  + strzero(day(cEmissao),2) + " de Dezembro de " + strzero(year(cEmissao),4) + ".", oFont23  )   
   EndCase

   _nLin := _nLin + 200

   oPrint:Say( _nLin, 0150, "______________________________________", oFont23  )   
   _nLin := _nLin + 70

   If Substr(cComboBx1,01,02) == "01"
      oPrint:Say( _nLin, 0150, "Automatech Sistemas de Automação Ltda", oFont23  )   
   Else
      oPrint:Say( _nLin, 0150, Alltrim(T_RECIBO->NOME), oFont23  )   
   Endif         

   // Encerra Relatório
   oPrint:EndPage()

   // Preview do Relatório
   oPrint:Preview()

   If Select("T_DEMO") > 0
      T_DEMO->( dbCloseArea() )
   EndIf

   MS_FLUSH()

Return .T.