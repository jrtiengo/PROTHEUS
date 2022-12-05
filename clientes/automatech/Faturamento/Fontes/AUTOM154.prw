#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM154.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/02/2012                                                          *
// Objetivo..: Programa que emite o relat�rio da Consulta do SERASA                *
//**********************************************************************************

User Function AUTOM154()

   Local lChumba  := .F.
   Local cCodigo  := M->A1_COD
   Local cLoja 	  := M->A1_LOJA
   Local cNomeCli := M->A1_NOME

   Local oGet1
   Local oGet2
   Local oGet3

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOM154")

   // Carrega as consultas realizadas para o cliente selecionado
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ6_FILIAL, "
   cSql += "       ZZ6_CODI  , "
   cSql += "       ZZ6_DATA  , "
   cSql += "       ZZ6_HORA  , "
   cSql += "       ZZ6_USUA  , "
   cSql += "       ZZ6_TIPO  , "
   cSql += "       ZZ6_CLIE  , "
   cSql += "       ZZ6_LOJA  , "
   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_HIST)) AS HISTORICO, "
   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_POSI)) AS POSICAO  , "
   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_RETO)) AS RETORNO    "
   cSql += " FROM " + RetSqlName("ZZ6")
   cSql += " WHERE ZZ6_CLIE = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND ZZ6_LOJA = '" + Alltrim(cLoja)   + "'"
   cSql += "   AND ZZ6_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   aBrowse := {}
   WHILE !T_SERASA->( EOF() )
      aAdd( aBrowse, { Substr(T_SERASA->ZZ6_DATA,07,02) + "/" + ;
                       Substr(T_SERASA->ZZ6_DATA,05,02) + "/" + ;
                       Substr(T_SERASA->ZZ6_DATA,01,04)        ,;
                       T_SERASA->ZZ6_HORA                      ,;
                       Alltrim(T_SERASA->ZZ6_CODI)             ,;
                       Alltrim(T_SERASA->ZZ6_USUA)             ,;
                       IIF(T_SERASA->ZZ6_TIPO == 1, "CREDNET", "RELATO")} )
      T_SERASA->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '', '', '', '', '' } )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Hist�rico de Consulta SERASA" FROM C(178),C(181) TO C(624),C(631) PIXEL

   @ C(005),C(005) Say "Cliente"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Consultas Realizadas" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1 Var cCodigo  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(031) MsGet oGet2 Var cLoja    When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(050) MsGet oGet3 Var cNomeCli When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(208),C(005) Button "Visualizar Consulta" Size C(059),C(012) PIXEL OF oDlg ACTION( VisualSerasa( aBrowse[ oBrowse:nAt, 03 ] ) )
   @ C(208),C(183) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TSBrowse():New(045,005,277,215,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Data',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('C�digo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Usu�rio',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Tipo Consulta',,,{|| },{|| }) )      
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que prepara a impress�o do relat�rio
Static Function VisualSerasa( cConsulta )

   // Declaracao de Variaveis
   Local titulo         := "Consulta SERASA Expirian"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}
   Local nContar        := 0
   Local cSeparadores   := ""

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 220
   Private tamanho      := "G"
   Private nomeprog     := "Consulta SERASA Expirian"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Consulta SERASA Expirian"
   Private cString      := "SC5"
   Private aPosicao     := {}
   Private aConteudo    := {}

   // Inicializa o Array de Retorno da Requisi��o 
   aAdd( aPosicao, { "N20000", "", "Dados Cadastrais"                   , "07,70|77,08|85,02|87,08|95,21|"                                     , "Raz�o Social|Data Nascimento/Funda��o|Situa��o CPF/CNPJ|Data Situa��o CPF/CNPJ|Reservado|" } )
   aAdd( aPosicao, { "N20001", "", "Dados Cadastrais"                   , "07,40|47,69|"                                                       , "Nome M�e dp CPF|Reservado|" } )
   aAdd( aPosicao, { "N21000", "", "Alerta de Documentos Roubados"      , "07,02|09,02|11,06|17,20|37,04|41,10|51,59|"                         , "N� da mensagem|Total de mensagens|Tipo de Documento|N� do Documento|Motivo da Ocorr�ncia|Data da Ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N21001", "", "Alerta de Documentos Roubados"      , "07,03|10,08|18,03|21,08|29,03|32,08|40,76|"                         , "C�digo DDD 1|N� do Telefone 1|C�digo DDD 2|N� do Telefone 2|C�digo DDD3|N� do Telefone 3|Reservado|" } )
   aAdd( aPosicao, { "N21099", "", "Alerta de Documentos Roubados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N22000", "", "Nada Consta"                        , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N23000", "", "Pend�ncia Interna / Pefin de Grupo" , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114|02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N23090", "", "Pend�ncia Interna / Pefin de Grupo" , "07,05|12,06|18,06|24,15|39,77|"                                     , "Total de Ocorr�ncias|Data da Ocorr�ncia mais antiga|Data da Ocorr~encia mais recente|Valor total das Pend�ncias Internas|Reservado|"} )
   aAdd( aPosicao, { "N23099", "", "Pend�ncia Interna / Pefin de Grupo" , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N24000", "", "Pend�ncia Financeira"               , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114,02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N24001", "", "Pend�ncia Financeira"               , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o - D�vida Vencida|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N24090", "", "Pend�ncia Financeira"               , "07,05|12,06|18,06|24,15|39,01|40,76|"                               , "Total de Ocorr�ncias|Data da ocorr�ncia mais antiga|Data da ocorr�ncia mais recente|Valor total das Pend�ncias Financeiras|Tipo de anota��o - D�vida Vencida|Reservado|" } )
   aAdd( aPosicao, { "N24099", "", "Pend�ncia Financeira"               , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N25000", "", "Protesto Estadual / Nacional"       , "07,08|15,03|18,15|33,02|35,30|65,02|78,38|"                         , "Data da Ocorr�ncia|Tipo de Moeda|Valor|Cart�rio|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N25001", "", "Protesto Estadual / Nacional"       , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o - D�vida Vencida|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N25090", "", "Protesto Estadual / Nacional"       , "07,05|12,06|18,06|24,03|27,15|42,74|"                               , "Total de Ocorr�ncias|Data da ocorr�ncia mais antiga|Data da ocorr�ncia mais recente|Moeda|Valor Total das Pend�ncias Financeiras|Reservado|" } )
   aAdd( aPosicao, { "N25099", "", "Protesto Estadual / Nacional"       , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N26090", "", "Cheque sem fundos Varejo"           , "07,05|12,08|20,03|23,12|35,04|39,30|69,04|73,04|77,39|"             , "Total de Ocorr�ncias|Data da Ocorr�ncia|N� do Banco|Nome Fantasia do Banco|Ag�ncia|Origem da Ocorr�ncia|Sigla Embratel|N� da Loja ou Filial|Reservado|" } )
   aAdd( aPosicao, { "N26099", "", "Cheque sem fundos Varejo"           , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N27090", "", "Cheque sem fundos BACEN"            , "07,05|12,08|20,08|28,03|31,04|35,12|47,69|"                         , "Total de Ocorr�ncia|Data da Ocorr�ncia mais antiga|Data da ocorr�ncia mais recente|N� do Banco|Ag�ncia|Nome Fantasia do Banco|Reservado|" } )
   aAdd( aPosicao, { "N27099", "", "Cheque sem fundos BACEN"            , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N41000", "", "Endere�o do CEP"                    , "07,70|77,30|107,09|"                                                , "Endere�o do CEP|Bairro|Reservado|" } )
   aAdd( aPosicao, { "N41001", "", "Endere�o do CEP"                    , "07,30|37,02|39,01|40,76|"                                           , "Cidade|UF|CEP Gen�rico|Reservado|" } )
   aAdd( aPosicao, { "N41099", "", "Endere�o do CEP"                    , "07,40|47,69|"                                                       , "Mensagem|Rseservado|" } )
   aAdd( aPosicao, { "N42000", "", "Endere�o do Telefone"               , "07,01|08,70|78,01|79,01|80,08|88,28|"                               , "Doc assinante do telefone confere com o doc consultado|Nome do Assinante|Tipo de Documento do Assinante|Classe do Assinante|Data Instala��o da linha telef�nica|Reservado|" } )
   aAdd( aPosicao, { "N42001", "", "Endere�o do Telefone"               , "07,70|77,30|107,09|"                                                , "Logradouro do Assinante|Bairro do Assinante|Reservado|" } )
   aAdd( aPosicao, { "N42002", "", "Endere�o do Telefone"               , "07,30|37,08|45,71|"                                                 , "Cidade do Assinante|CEP do Assinante|Reservado|" } )
   aAdd( aPosicao, { "N42099", "", "Endere�o do Telefone"               , "07,01|08,40|48,68|"                                                 , "Indicador de Pesquisa|Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N43000", "", "�ltimos telefones consultados"      , "07,30|10,08|18,03|21,08|29,03|32,08|40,03|43,08|51,03|54,08|62,54|" , "1� mais recente - DDD telefone pesquisado|1� mais recente - N� teledone pesquisado|2� mais recente - DDD telefone pesquisado|2� mais recente - N� telefone pesquisado|3� mais recente - DDD telefone pesquisado|3� mais recente - N� telefone pesquisado|4� mais recente - DDD telefone pesquisado|4� mais recente - N� telefone pesquisado|5� mais recente - DDD telefone pesquisado|5� mais recente - N� telefone pesquisado|Reservado|" } )
   aAdd( aPosicao, { "N43099", "", "�ltimos telefones consultados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N44000", "", "Registro de Consultas"              , "07,04|11,04|15,03|18,02|20,02|22,02|24,03|27,89|"                   , "Registros de consulta efetuados no pr�prio estabelecimento|Data emiss�o 1� Cheque � vista|Data emiss�o �ltimo cheque � vista|Total cheques � vista emitidos nos �ltimos 15 dias|Total de cheques � prazo emitidos nos �ltimos 30 dias|Total de cheques � prazo emitidos nos �ltimos entre 31 e 60 dias|Total de cheques � prazo emitidos nos �ltimos entre 61 e 90 dias|Total de cheques � prazo emitidos|Reservado|" } ) 
   aAdd( aPosicao, { "N44001", "", "Registro de Consultas"              , "07,04|11,04|15,03|18,02|20,02|22,02|24,03|27,89|"                   , "Data da emiss�o dos primeiro cheque � vista|Data da emiss�o do �ltimo cheque � vista|Total de cheques � vista emitidos nos �ltimos 15 dias|Total de cheques � prazo emitidos nos �ltimos 30 dias|Total de cheques � prazo emitidos nos �ltimos entre 31 e 60 Dias|Total de cheques � prazo emitidos nos �ltimos entre 61 e 90 dias|Total de Cheques � prazo emitidos|Reservado|"  } ) 
   aAdd( aPosicao, { "N44002", "", "Registro de Consultas"              , "07,25|32,04|36,25|61,04|65,25|90,04|94,22|"                         , "1� mais recente - Nome da empresa consultante|1� mais recente - Data da consulta do cheque|2� mais recente - Nome da empresa consultante|2� mais recente - Data da consulta do cheque|3� mais recente - Nome da empresa consultante|3� mais recente - Data da consulta do cheque|Reservado|" } ) 
   aAdd( aPosicao, { "N44003", "", "Registro de Consultas"              , "07,03|10,03|13,03|16,03|19,97|"                                     , "Quantidade de consultas realizadas nos �ltimos 15 dias|Quantidade de consultas realizadas entre 16 e 30 dias|Quantidade de consultas realizadas entre 31 e 60 dias|Quantidade de consultas realizadas entre 61 e 90 dias|Reservado|" } ) 
   aAdd( aPosicao, { "N44099", "", "Registro de Consultas"              , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } ) 

   // Consist�ncia dos Dados
   If Empty(Alltrim(cConsulta))
      MsgAlert("Necess�rio selecionar uma consulta para visualiza��o.")
      Return .T.
   Endif
      
   // Pesquisa os dados a serem listados
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ6_FILIAL, "
   cSql += "       ZZ6_CODI    "
   cSql += " FROM " + RetSqlName("ZZ6")
   cSql += " WHERE ZZ6_CODI = '" + Alltrim(cConsulta) + "'"
   cSql += "   AND ZZ6_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   T_SERASA->( DbGoTop() )

   If T_SERASA->( Eof() )
      MsgAlert("N�o existem dados a serem visualizados.")
      Return .T.
   Endif

   // Envia para a fun��o que imprime o relat�rio
   Processa( {|| LISTASERASA(Cabec1,Cabec2,cVendedor,nLin) }, "Aguarde...", "Gerando Relat�rio",.F.)

Return .T.

// Fun��o que gera o relat�rio
Static Function LISTASERASA(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor := ""
   Local cCliente  := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0
   Local _Vendedor := ""
   Local xContar   := 0
   Local nContar   := 0

   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 3000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

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
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Pesquisa os dados para impress�o
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ6_FILIAL, "
   cSql += "       ZZ6_CODI    "
//       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ7_RETO)) AS HISTORICO
   cSql += " FROM " + RetSqlName("ZZ6")
   cSql += " WHERE ZZ6_CODI = '" + Alltrim(cConsulta) + "'"
   cSql += "   AND ZZ6_DELE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )





   // Carrega o Array aPesquisa com os dados dos 5 poss�veis vendedores
   T_CANCELADAS->( DbGoTop() )
   While !T_CANCELADAS->( EOF() )

       For nContar = 1 to 5
           
           xVendedor := "999999"

           Do Case
              Case nContar = 1
                   If Empty(t_canceladas->F2_vend1)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend1) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend1
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_canceladas->F2_Vend1
                      Endif
                   Endif

              Case nContar = 2
                   If Empty(t_canceladas->F2_vend2)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend2) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend2
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_canceladas->F2_Vend2
                      Endif
                   Endif

              Case nContar = 3
                   If Empty(t_canceladas->F2_vend3)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend3) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend3
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_cancealdas-F2_Vend3
                      Endif
                   Endif

              Case nContar = 4
                   If Empty(t_canceladas->F2_vend4)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(tcanceladas->F2_Vend4) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend4
                         Else
                            Loop
                         Endif
                      Else
                         xvendedor := t_canceladas->F2_Vend4
                      Endif
                   Endif

              Case nContar = 5
                   If Empty(t_canceladas->F2_vend5)
                      Loop
                   Else
                      If !Empty(titulo)
                         If Alltrim(t_canceladas->F2_Vend5) == Alltrim(titulo)
                            xVendedor := t_canceladas->F2_vend5
                         Else
                            Loop
                         Endif
                      Else
                         xVendedor := t_cancealdas->F2_Vend5
                      Endif
                   Endif

           EndCase
                         
           // Pesquisa o Nome do Vendedor
           If xVendedor == "999999"
              cNomevendedor := "SEM VENDEDOR"
           Else   
              If Select("T_VENDEDOR") > 0
                 T_VENDEDOR->( dbCloseArea() )
              EndIf

              cSql := ""
              cSql := "SELECT A3_NOME  , "
              cSql += "       A3_NREDUZ, "
              cSql += "       A3_EMAIL   "
              cSql += "  FROM " + RetSqlName("SA3010")
              cSql += " WHERE A3_COD = '" + Alltrim(xVendedor) + "'"
               
              cSql := ChangeQuery( cSql )
              dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

              If !T_VENDEDOR->( Eof() )
                 cNomeVendedor := T_VENDEDOR->A3_NOME
              Else
                 cNomeVendedor := Space(40)
              Endif

              T_VENDEDOR->( dbCloseArea() )
                 
           Endif   

           // Carrega o Array
           aPesq := {xVendedor                ,; // 01 - C�digo do vendedor
                     cNomeVendedor            ,; // 02 - Nome do Vendedor
                     T_CANCELADAS->F2_FILIAL  ,; // 03 - Filial
                     T_CANCELADAS->F2_DOC     ,; // 04 - N� da Nota Fiscal
                     T_CANCELADAS->F2_SERIE   ,; // 05 - N� de S�rie
                     T_CANCELADAS->F2_EMISSAO ,; // 06 - Data de Emiss�o
                     T_CANCELADAS->F2_CLIENTE ,; // 07 - C�digo do Cliente
                     T_CANCELADAS->F2_LOJA    ,; // 08 - C�digo da Loja
                     T_CANCELADAS->A1_NOME    ,; // 09 - Nome do Cliente
                     T_CANCELADAS->F2_VALBRUT ,; // 10 - Valor Bruto da Nota Fiscal
                     T_CANCELADAS->F2_CHVNFE}    // 11 - Chave de Acesso
       
           aAdd( aPesquisa, aPesq )
       
       Next nContar
       
       T_CANCELADAS->( DbSkip() )
       
   Enddo

   // Ordena o Array para Impress�o
   ASORT(aPesquisa,,,{ | x,y | x[1] + x[3] + x[4] < y[1] + y[3] + y[4] } )

  If Len(aPesquisa) == 0
      Msgalert("N�o existem dados a serem visualizadas.")
      Return .T.
   Endif

   cVendedor := aPesquisa[01,01]
   cNomeVend := aPesquisa[01,02]

   // Acumuladores
   nQtd      := 0
   nVendedor := 0
   nGeral    := 0
   nPagina   := 0
   _nLin     := 10
      
   ProcRegua( Len(aPesquisa) )

   // Envia para a fun��o que imprime o cabe�alho dp relat�rio
   CABECACAN(cNomevend, nPagina)

   For nContar = 1 to Len(aPesquisa)
   
      If Alltrim(aPesquisa[nContar,1]) == Alltrim(cVendedor)

         // Impress�o dos dados
         oPrint:Say(_nLin, 0100, aPesquisa[nContar,03]              , oFont21)  
         oPrint:Say(_nLin, 0230, Substr(aPesquisa[nContar,04],01,06), oFont21)  
         oPrint:Say(_nLin, 0400, aPesquisa[nContar,05]              , oFont21)  
         oPrint:Say(_nLin, 0550, Substr(aPesquisa[nContar,06],07,02) + "/" + Substr(aPesquisa[nContar,06],05,02) + "/" + Substr(aPesquisa[nContar,06],01,04), oFont21)  
         oPrint:Say(_nLin, 0800, aPesquisa[nContar,09], oFont21)  
         oPrint:Say(_nLin, 1440, Str(aPesquisa[nContar,10],12,02), oFont21)  
         oPrint:Say(_nLin, 1690, aPesquisa[nContar,11], oFont21)

         nQtd      := nQtd      + 1
         nVendedor := nVendedor + aPesquisa[nContar,10]
         nGeral    := nGeral    + aPesquisa[nContar,10]

         SomaLinhaCan(50,cVendedor)

         Loop

      Else

         SomaLinhaCan(50,cVendedor)
                                                                                                       
         oPrint:Say(_nLin, 0960, "QUANTIDADE DE NF CANCELADAS: ", oFont21)
         oPrint:Say(_nLin, 1440, Str(nQtd,12)                   , oFont21)  
         SomaLinhaCan(50,cVendedor)
         oPrint:Say(_nLin, 0960, "VALOR TOTAL DE NF CANCELADAS:", oFont21)
         oPrint:Say(_nLin, 1440, Str(nVendedor,12,02)           , oFont21)  

         nQtd      := 0
         nVendedor := 0

         cVendedor := aPesquisa[nContar,01]
         cNomeVend := aPesquisa[nContar,02]

         SomaLinhaCan(100,cVendedor)            
          
         oPrint:Say(_nLin, 0800, "VENDEDOR: " + Alltrim(cNomevend), oFont10b)  

         SomaLinhaCan(100,cVendedor)

         nContar := nContar - 1

      Endif

   Next nContar

   SomaLinhaCan(50,cVendedor)
                                                                                                       
   oPrint:Say(_nLin, 0960, "QUANTIDADE DE NF CANCELADAS: ", oFont21)
   oPrint:Say(_nLin, 1490, Str(nQtd,12)                   , oFont21)  
   SomaLinhaCan(50,cVendedor)
   oPrint:Say(_nLin, 0960, "VALOR TOTAL DE NF CANCELADAS:", oFont21)
   oPrint:Say(_nLin, 1490, Str(nVendedor,12,02)           , oFont21)  

   oPrint:EndPage()

   oPrint:Preview()

   If Select("T_CANCELADAS") > 0
      T_CANCELADAS->( dbCloseArea() )
   Endif
   
   MS_FLUSH()

Return .T.

// Imprime o cabe�alho do relat�rio
Static Function CABECACAN(cNomeVend, nPagina)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60

   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA", oFont21)
   oPrint:Say( _nLin, 1000, "RELA��O NF CANCELADAS POR VENDEDOR"   , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()            , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR31.PRW", oFont21)
   oPrint:Say( _nLin, 1000, "PER�ODO DE " + Dtoc(dData01) + " A " + Dtoc(dData02), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20

   oPrint:Say( _nLin, 0100, "FL"                    , oFont21)  
   oPrint:Say( _nLin, 0230, "NFISCAL"               , oFont21)  
   oPrint:Say( _nLin, 0400, "SEIRE"                 , oFont21)  
   oPrint:Say( _nLin, 0550, "EMISS�O"               , oFont21)  
   oPrint:Say( _nLin, 0800, "DESCRI��O DOS CLIENTES", oFont21)  
   oPrint:Say( _nLin, 1478, "VALOR TOTAL"           , oFont21)  
   oPrint:Say( _nLin, 1690, "CHAVE ACESSO"          , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 50

   oPrint:Say( _nLin, 0800, "VENDEDOR: " + Alltrim(cNomeVend), oFont10b)

   _nLin += 60

Return .T.

// Fun��o que soma linhas para impress�o
Static Function SomaLinhaCan(nLinhas,cVendedor)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:Line( _nLin, 0100, _nLin, 2400 )
      oPrint:EndPage()
      CABECACAN(cVendedor, nPagina)
   Endif
   
Return .T.      
