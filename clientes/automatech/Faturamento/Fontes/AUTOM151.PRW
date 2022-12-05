#INCLUDE "TOTVS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ## 
// Referencia: AUTOM151.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 04/02/2013                                                          ##
// Objetivo..: Programa que dispara a consulta ao Serasa                           ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: Consulta Serasa                                                     ##
// ##################################################################################

User Function AUTOM151()

   Local lChumba    := .F.
   Local aConsulta  := {"1 - Pendências Financeiras + Protesto Estadual","2 - Relato Analítico"}
   Local cCliente   := Alltrim(m->a1_cod) + "." + Alltrim(m->a1_loja) + " - " + Alltrim(m->a1_nome)
   Local cDocumento := Alltrim(m->a1_cgc)
   Local cUrl       := ""
   Local nTimeOut   := 0
   Local aHeadOut   := {}
   Local cHeadRet   := ""
   Local sPostRet   := Nil
   Local cSql       := ""

   Local cComboBx1
   Local oGet1
   Local oGet2

   Private oDlg
	
   Private cPedido01 := ""
   Private lTodas    := .F.

   U_AUTOM628("AUTOM151")

   // #########################################
   // Prepara o campo documento para display ##
   // #########################################
   If Len(Alltrim(m->a1_cgc)) == 11
      cDocumento := Substr(m->a1_cgc,01,03) + "." + ;
                    Substr(m->a1_cgc,04,03) + "." + ;
                    Substr(m->a1_cgc,07,03) + "-" + ;   
                    Substr(m->a1_cgc,10,02)
   Else
      cDocumento := Substr(m->a1_cgc,01,02) + "." + ;
                    Substr(m->a1_cgc,03,03) + "." + ;
                    Substr(m->a1_cgc,06,03) + "/" + ;   
                    Substr(m->a1_cgc,09,04) + "-" + ;
                    Substr(m->a1_cgc,13,03)
   Endif

   // ##############################################################
   // Pesquisa os parâmentros do Serasa nos Parâmetros Automatech ##
   // ##############################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA,"
   cSql += "       ZZ4_LOGO,"
   cSql += "       ZZ4_SENH,"
   cSql += "       ZZ4_NOVA,"
   cSql += "       ZZ4_HOMO,"
   cSql += "       ZZ4_PROD," 
   cSql += "       ZZ4_AMBI,"
   cSql += "       ZZ4_TIME "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Parametrização Serasa inexistente. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_SERA))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // ###################################################################################
   // Verifica se o usuário logado possui autorização para realizar consulta ao Serasa ##
   // ###################################################################################
   If U_P_OCCURS(T_PARAMETROS->ZZ4_SERA, Alltrim(Upper(cUserName)), 1) == 0
      MsgAlert("Atenção! Você não tem permissão para executar este procedimento.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_LOGO))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif
      
   If Empty(Alltrim(T_PARAMETROS->ZZ4_SENH))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_HOMO))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_PROD))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If T_PARAMETROS->ZZ4_TIME == 0
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // Desenha a tela de solicitação dos dados para consulta ao Serasa Expirian
   DEFINE MSDIALOG oDlg TITLE "Consulta Serasa Expirian"  FROM C(178),C(181) TO C(319),C(657) PIXEL

   @ C(005),C(005) Say "Cliente a ser consultado"         Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Documento do Cliente"             Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(094) Say "Tipo de consulta a ser realizada" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var cCliente    When lChumba Size C(227),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(005) MsGet    oGet2     Var cDocumento  When lChumba Size C(065),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(094) ComboBox cComboBx1 Items aConsulta When lChumba Size C(138),C(010) PIXEL OF oDlg

   // @ C(053),C(005) CheckBox oCheckBox1 Var lTodas   Prompt "LIMITE DE CRÉDITO" Size C(097),C(008) PIXEL OF oDlg

   @ C(052),C(154) Button "Consultar" Size C(037),C(012) PIXEL OF oDlg ACTION( DispCons( m->a1_cgc, cComboBx1) )
   @ C(052),C(194) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ################################################################
// Função que dispara a pesquisa conforme indicação pelo usuário ##
// ################################################################
Static Function DispCons( _Documento, _Tipo)

   Local cSql       := ""
   Local cString1   := ""
   Local cString2   := ""
   Local cString3   := ""
   Local cString4   := ""
   Local cString5   := ""
   Local cUrl       := ""
   Local nTimeOut   := 0
   Local aHeadOut   := {}
   Local cHeadRet   := ""
   Local sPostRet   := Nil
   Local cTime      := 0
   Local cCertifi   := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_cert.pem"
   Local cChave     := "\\srverp\Protheus\Protheus11\Protheus_data\certs\000001_key.pem"
   Local nPosicao   := ""
   Local nContar    := 0
   Local cTexto1    := ""
   Local cTexto2    := ""
   Local aConteudo  := {}
   Local cConteudo  := ""
   Local nCorta     := 0
   Local cQuebra    := ""
   Local lPrimeiro  := .T.
   Local cNovoCod   := ""
   Local _x_Senha   := ""
   Local _TTitulos  := 0
 
   Local aArea := GetArea()

   // ##############################################
   // Inicializa o Array de Retorno da Requisição ##
   // ##############################################
   Local aPosicao := {}

   aAdd( aPosicao, { "N20000", "", "Dados Cadastrais"                   , "07,70|77,08|85,02|87,08|95,21|"                                     , "Razão Social|Data Nascimento/Fundação|Situação CPF/CNPJ|Data Situação CPF/CNPJ|Reservado|" } )
   aAdd( aPosicao, { "N20001", "", "Dados Cadastrais"                   , "07,40|47,69|"                                                       , "Nome Mãe do CPF|Reservado|" } )
   aAdd( aPosicao, { "N21000", "", "Alerta de Documentos Roubados"      , "07,02|09,02|11,06|17,20|37,04|41,10|51,59|"                         , "Nº da mensagem|Total de mensagens|Tipo de Documento|Nº do Documento|Motivo da Ocorrência|Data da Ocorrência|Reservado|" } )
   aAdd( aPosicao, { "N21001", "", "Alerta de Documentos Roubados"      , "07,03|10,08|18,03|21,08|29,03|32,08|40,76|"                         , "Código DDD 1|Nº do Telefone 1|Código DDD 2|Nº do Telefone 2|Código DDD3|Nº do Telefone 3|Reservado|" } )
   aAdd( aPosicao, { "N21099", "", "Alerta de Documentos Roubados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N22000", "", "Nada Consta"                        , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N23000", "", "Pendência Interna / Pefin de Grupo" , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114|02|"           , "Data da Ocorrência|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da praça da ocorrência|Reservado|" } )
   aAdd( aPosicao, { "N23090", "", "Pendência Interna / Pefin de Grupo" , "07,05|12,06|18,06|24,15|39,77|"                                     , "Total de Ocorrências|Data da Ocorrência mais antiga|Data da Ocorr~encia mais recente|Valor total das Pendências Internas|Reservado|"} )
   aAdd( aPosicao, { "N23099", "", "Pendência Interna / Pefin de Grupo" , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N24000", "", "Pendência Financeira"               , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114,02|"           , "Data da Ocorrência|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da praça da ocorrência|Reservado|" } )
   aAdd( aPosicao, { "N24001", "", "Pendência Financeira"               , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anotação Subjúdice|Mensagem Subjúdice|Tipo de anotação - Dívida Vencida|Código do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N24090", "", "Pendência Financeira"               , "07,05|12,06|18,06|24,15|39,01|40,76|"                               , "Total de Ocorrências|Data da ocorrência mais antiga|Data da ocorrência mais recente|Valor total das Pendências Financeiras|Tipo de anotação - Dívida Vencida|Reservado|" } )
   aAdd( aPosicao, { "N24099", "", "Pendência Financeira"               , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N25000", "", "Protesto Estadual / Nacional"       , "07,08|15,03|18,15|33,02|35,30|65,02|78,38|"                         , "Data da Ocorrência|Tipo de Moeda|Valor|Cartório|Origem|Sigla Embratel da praça da ocorrência|Reservado|" } )
   aAdd( aPosicao, { "N25001", "", "Protesto Estadual / Nacional"       , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anotação Subjúdice|Mensagem Subjúdice|Tipo de anotação - Dívida Vencida|Código do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N25090", "", "Protesto Estadual / Nacional"       , "07,05|12,06|18,06|24,03|27,15|42,74|"                               , "Total de Ocorrências|Data da ocorrência mais antiga|Data da ocorrência mais recente|Moeda|Valor Total das Pendências Financeiras|Reservado|" } )
   aAdd( aPosicao, { "N25099", "", "Protesto Estadual / Nacional"       , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N26090", "", "Cheque sem fundos Varejo"           , "07,05|12,08|20,03|23,12|35,04|39,30|69,04|73,04|77,39|"             , "Total de Ocorrências|Data da Ocorrência|Nº do Banco|Nome Fantasia do Banco|Agência|Origem da Ocorrência|Sigla Embratel|Nº da Loja ou Filial|Reservado|" } )
   aAdd( aPosicao, { "N26099", "", "Cheque sem fundos Varejo"           , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N27090", "", "Cheque sem fundos BACEN"            , "07,05|12,08|20,08|28,03|31,04|35,12|47,69|"                         , "Total de Ocorrência|Data da Ocorrência mais antiga|Data da ocorrência mais recente|Nº do Banco|Agência|Nome Fantasia do Banco|Reservado|" } )
   aAdd( aPosicao, { "N27099", "", "Cheque sem fundos BACEN"            , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N41000", "", "Endereço do CEP"                    , "07,70|77,30|107,09|"                                                , "Endereço do CEP|Bairro|Reservado|" } )
   aAdd( aPosicao, { "N41001", "", "Endereço do CEP"                    , "07,30|37,02|39,01|40,76|"                                           , "Cidade|UF|CEP Genérico|Reservado|" } )
   aAdd( aPosicao, { "N41099", "", "Endereço do CEP"                    , "07,40|47,69|"                                                       , "Mensagem|Rseservado|" } )
   aAdd( aPosicao, { "N42000", "", "Endereço do Telefone"               , "07,01|08,70|78,01|79,01|80,08|88,28|"                               , "Doc assinante do telefone confere com o doc consultado|Nome do Assinante|Tipo de Documento do Assinante|Classe do Assinante|Data Instalação da linha telefônica|Reservado|" } )
   aAdd( aPosicao, { "N42001", "", "Endereço do Telefone"               , "07,70|77,30|107,09|"                                                , "Logradouro do Assinante|Bairro do Assinante|Reservado|" } )
   aAdd( aPosicao, { "N42002", "", "Endereço do Telefone"               , "07,30|37,08|45,71|"                                                 , "Cidade do Assinante|CEP do Assinante|Reservado|" } )
   aAdd( aPosicao, { "N42099", "", "Endereço do Telefone"               , "07,01|08,40|48,68|"                                                 , "Indicador de Pesquisa|Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N43000", "", "Últimos telefones consultados"      , "07,30|10,08|18,03|21,08|29,03|32,08|40,03|43,08|51,03|54,08|62,54|" , "1º mais recente - DDD telefone pesquisado|1º mais recente - Nº teledone pesquisado|2º mais recente - DDD telefone pesquisado|2º mais recente - Nº telefone pesquisado|3º mais recente - DDD telefone pesquisado|3º mais recente - Nº telefone pesquisado|4º mais recente - DDD telefone pesquisado|4º mais recente - Nº telefone pesquisado|5º mais recente - DDD telefone pesquisado|5º mais recente - Nº telefone pesquisado|Reservado|" } )
   aAdd( aPosicao, { "N43099", "", "Últimos telefones consultados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N44000", "", "Registro de Consultas"              , "07,04|11,04|15,03|18,02|20,02|22,02|24,03|27,89|"                   , "Registros de consulta efetuados no próprio estabelecimento|Data emissão 1º Cheque à vista|Data emissão último cheque à vista|Total cheques à vista emitidos nos últimos 15 dias|Total de cheques à prazo emitidos nos últimos 30 dias|Total de cheques à prazo emitidos nos últimos entre 31 e 60 dias|Total de cheques à prazo emitidos nos últimos entre 61 e 90 dias|Total de cheques à prazo emitidos|Reservado|" } ) 
   aAdd( aPosicao, { "N44001", "", "Registro de Consultas"              , "07,04|11,04|15,03|18,02|20,02|22,02|24,03|27,89|"                   , "Data da emissão dos primeiro cheque à vista|Data da emissão do último cheque à vista|Total de cheques à vista emitidos nos últimos 15 dias|Total de cheques à prazo emitidos nos últimos 30 dias|Total de cheques à prazo emitidos nos últimos entre 31 e 60 Dias|Total de cheques à prazo emitidos nos últimos entre 61 e 90 dias|Total de Cheques à prazo emitidos|Reservado|"  } ) 
   aAdd( aPosicao, { "N44002", "", "Registro de Consultas"              , "07,25|32,04|36,25|61,04|65,25|90,04|94,22|"                         , "1º mais recente - Nome da empresa consultante|1º mais recente - Data da consulta do cheque|2º mais recente - Nome da empresa consultante|2º mais recente - Data da consulta do cheque|3º mais recente - Nome da empresa consultante|3º mais recente - Data da consulta do cheque|Reservado|" } ) 
   aAdd( aPosicao, { "N44003", "", "Registro de Consultas"              , "07,03|10,03|13,03|16,03|19,97|"                                     , "Quantidade de consultas realizadas nos últimos 15 dias|Quantidade de consultas realizadas entre 16 e 30 dias|Quantidade de consultas realizadas entre 31 e 60 dias|Quantidade de consultas realizadas entre 61 e 90 dias|Reservado|" } ) 
   aAdd( aPosicao, { "N44099", "", "Registro de Consultas"              , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } ) 
   aAdd( aPosicao, { "N62000", "", "Limite de Crédito PJ"               , "07,13|"                                                             , "Valor Limite de Crédito Pessoa Jurídica|" } ) 
   aAdd( aPosicao, { "N62090", "", "Observações Limite de Crédito PJ"   , "07,79|"                                                             , "Observações LC PJ|" } )
   aAdd( aPosicao, { "B3702" , "", "Limite de Crédito PF"               , "124,09|"                                                            , "Limite de Crédito PF|" } )

   // ##############################################################
   // Pesquisa os parâmentros do Serasa nos Parâmetros Automatech ##
   // ##############################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA,"
   cSql += "       ZZ4_LOGO,"
   cSql += "       ZZ4_SENH,"
   cSql += "       ZZ4_NOVA,"
   cSql += "       ZZ4_HOMO,"
   cSql += "       ZZ4_PROD," 
   cSql += "       ZZ4_AMBI,"
   cSql += "       ZZ4_TIME "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   // #############################################################################
   // Prepara a pesquisa 1 - Consulta Pendências Financeiras + Protesto Estadual ##
   // #############################################################################
   If Substr(_Tipo,01,01) == "1"

      // #############################
      // Comando B49C - Obrigatório ##
      // #############################
      cString1 := ""
      cString1 := "B49C"                           // 001 - Fixo B49C
      cString1 += Replicate("%20", 6)              // 005 - Brancos
      cString1 += Strzero(INT(VAL(_Documento)),15) // 011 - CPF/CNPJ
      cString1 += M->A1_PESSOA                     // 026 - F = Física, J = jurídica
	  cString1 += "C" + Replicate("%20", 5)        // 027 - Fixo C
      cString1 += "CH"                             // 033 - Fixo CH
      cString1 += "0000000"                        // 035 - Fixo 0000000
      cString1 += Replicate("%20",12)              // 042 - Brancos
      cString1 += "S"                              // 054 - Fixo S
      cString1 += "99"                             // 055 - Fixo 99
      cString1 += "S"                              // 057 - Fixo S
      cString1 += "INI"                            // 058 - Fixo INI
      cString1 += "A"                              // 061 - Fixo A
      cString1 += "N"                              // 062 - Fixo N
      cString1 += Replicate("%20", 30)             // 063 - Brancos
      cString1 += Replicate("%20", 1)              // 093 - Brancos
      cString1 += "N"                              // 094 - Fixo N
      cString1 += Replicate("%20", 10)             // 095 - Brancos
      cString1 += "00"                             // 105 - Fixo 00
      cString1 += "S"                              // 107 - S ou N
      cString1 += Replicate("%20", 8)              // 108 - Brancos
      cString1 += "000000000000000"                // 116 - Fixo 000000000000000
      cString1 += "S"                              // 131 - Fixo S
      cString1 += Replicate("%20", 9)              // 132 - Brancos
      cString1 += "1"                              // 141 - Fixo 1
      cString1 += Replicate("%20", 10)             // 142 - Brancos
      cString1 += Replicate("%20", 234)            // 167 - Brancos
      cString1 += Replicate("%20", 15)             // 398 - Brancos

      // #################
      // String2 - P002 ##
      // #################
      cString2 := ""

      If Alltrim(M->A1_PESSOA) == "F"

//       cString2 := "P002RE02%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20CLC7%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20"

         cString2 := "P002"
         cString2 += "RE02"
         cString2 += Replicate("%20", 21)
         cString2 += "CLC7"
         cString2 += Replicate("%20", 82)

      Else

         cString2 := "P002"
         cString2 += "RE02"
         cString2 += Replicate("%20", 107)

      Endif   

      // ################################
      // N001 - Pendências Financeiras ##
      // ################################
      cString3 := ""
      cString3 := "N001"               // 001 - Fixo N001
      cString3 += "00"                 // 005 - Subtipo (Fixo 00)
      cString3 += "PP"                 // 007 - Fixo PP
      cString3 += "X21P"               // 009 - Fixo X21P
      cString3 += Replicate("%20", 1)  // 013 - Brancos
      cString3 += "0"                  // 014 - Fixo 0
      cString3 += Replicate("%20", 1)  // 015 - Brancos
      cString3 += Replicate("%20", 1)  // 016 - Brancos
      cString3 += Replicate("%20", 1)  // 017 - Área reservada p/uso da SERASA
      cString3 += Replicate("%20", 1)  // 018 - Brancos
      cString3 += Replicate("%20", 7)  // 019 - Brancos
      cString3 += Replicate("%20", 12) // 026 - Brancos
      cString3 += Replicate("%20", 1)  // 038 - Brancos
      cString3 += Replicate("%20", 77) // 039 - Filler

      // ######################################
      // Solicita dados de Protesto Estadual ##
      // ######################################
      cString5 := ""
      cString5 := "N003"                                                  // 001 - Fixo N003
      cString5 += "00"                                                    // 005 - SubTipo = 00
      cString5 += Replicate("%20", 4)                                     // 007 - Código do DDD do Telefone a ser pesquisado
      cString5 += Replicate("%20", 8)                                     // 011 - Número do telefone a ser pesquisado
      cString5 += Substr(M->A1_CEP,01,05) + "-" + Substr(M->A1_CEP,06,03) // 019 - CEP a ser pesquisado
      cString5 += M->A1_EST                                               // 028 - UF para consulta a Protesto Estadual

      If Alltrim(M->A1_PESSOA) == "J"
         cString5 += "P8GT"                                               // 030 - FEAT-SCOR
      Else
         cString5 += Replicate("%20", 4)                                  // 030 - FEAT-SCOR
      Endif

      cString5 += Replicate("%20", 82)                                    // Filler

      // ###############################################
      // Comando finalizador do comando a ser enviado ##
      // ###############################################
      cString4 := ""
      cString4 := "T999"
      cString4 += Replicate("%20", 111)
      cString4 += CHR(13)
         
   Endif

   // Acrescenta o UserAgent na requisição ...
   // http://tools.ietf.org/html/rfc3261#page-179

   // Parâmetro de TimeOut
   nTimeOut := T_PARAMETROS->ZZ4_TIME

   // ---------------------------------- //
   // Até dia 19/06/2016                 //
   // 21841571 - @tech03  = "%40atech03" //
   // ---------------------------------- //
   // Apartir de 20/06/2016              //
   // 44422944 - @adm1605 = "%40adm1605" //
   // ---------------------------------- //

   // Gera a String de Requisição dos dados
   cUrl := IIF(Substr(T_PARAMETROS->ZZ4_AMBI,01,01) == "H", Alltrim(T_PARAMETROS->ZZ4_HOMO), Alltrim(T_PARAMETROS->ZZ4_PROD))  + ; 
           T_PARAMETROS->ZZ4_LOGO         + ;
           "%40adm1605"                 + ;
           IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_NOVA)), "%20%20%20%20%20%20%20%20", T_PARAMETROS->ZZ4_NOVA) + ;
           cString1 + cString2 + cString3 + cString5 + cString4

//           "%40tech00%20"                 + ;

//           T_PARAMETROS->ZZ4_SENH          + ;
 

   // Agente do Browser
   // aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')')
   aadd(aHeadOut,'User-Agent: Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; pt-BR)')

   // Envia a requisição ao SERASA
   sPostRet := HttpSPost(cUrl, "", "", "", "","",nTimeOut,aHeadOut,@cHeadRet)

   // #####################################################################
   // Display do retorno (Utilizado somente para teste do desenvolvedor) ##
   // msgalert(sPostRet)                                                 ##
   // #####################################################################

   // #####################
   // verifica o Retorno ##
   // #####################
   IF !Empty(AllTrim(sPostRet))

      If Substr(sPostRet,01,04) <> "B49C"
         MsgAlert("Atenção! Houve erro no envio/recebimento da solicitação da consulta ao SERASA." + chr(13) + ;
                  "Repita novamente a consulta."                                                   + chr(13) + ;
                  "Caso o erro persistir, entre em contato com o Administrados do Sistema.")
         Return(.T.)
      Endif

      // ###########################################################
      // Captura o posicionamento dos resultados a serem gravados ##
      // ###########################################################
      For nContar = 1 to Len(aPosicao)
          nPosicao := U_P_OCCURS(sPostRet, aPosicao[nContar,1], 2)
          If Empty(Alltrim(nPosicao))
             nPosicao := ""
          Else
             If U_P_OCCURS(nPosicao, "|", 1) == 0
                nPosicao := nPosicao + "|"
             Endif
          Endif
          aPosicao[nContar,2] := nPosicao
      Next nContar    

      // ####################################################
      // Separa os resultados e atualiza o array aConteudo ##
      // ####################################################
      aConteudo  := {}
      
      For nContar = 1 to Len(aPosicao)
          
          // ##################################
          // Despreza posicionamentos vazios ##
          // ##################################
          If Empty(Alltrim(aPosicao[nContar,2]))
             Loop
          Endif

          For nLinha = 1 to U_P_OCCURS(aPosicao[nContar,2], "|", 1)

              nCorta    := INT(VAL(U_P_CORTA(aPosicao[nContar,2], "|", nLinha)))
              cConteudo := Substr(sPostRet, nCorta, 115)
              
              If !Empty(Alltrim(cConteudo))
                 aAdd( aConteudo, { aPosicao[nContar,1], cConteudo } )
              Endif
                 
          Next nLinha

      Next nContar

      // #################################################################
      // Grava os dados da tabela ZZ6010 - Histórico do Serasa Experian ##
      // #################################################################

      // ######################################################################################
      // Pesquisa o Próximo código de controle para gravação do histórico do Serasa Expirian ##
      // ######################################################################################
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZ6_CODI "
      cSql += "  FROM " + RetSqlName("ZZ6")
      cSql += " WHERE ZZ6_DELE = ''"
      cSql += " ORDER BY ZZ6_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         cNovoCod := '000001'
      Else
         cNovoCod := Strzero((INT(VAL(T_NOVO->ZZ6_CODI)) + 1),6)      
      Endif

      cData := Date()
      cHora := Time()

      // ############################
      // Inseri os dados na Tabela ##
      // ############################
      dbSelectArea("ZZ6")
      RecLock("ZZ6",.T.)
      ZZ6_FILIAL := cFilAnt
      ZZ6_CODI   := cNovoCod
      ZZ6_DATA   := cData
      ZZ6_HORA   := cHora
      ZZ6_USUA   := Alltrim(Upper(cUserName))
      ZZ6_CLIE   := M->A1_COD
      ZZ6_LOJA   := M->A1_LOJA
      ZZ6_DELE   := ""
      ZZ6_TIPO   := INT(VAL(_Tipo))
      MsUnLock()

      // ##############################
      // Grava a tabela dos retornos ##
      // ##############################
      For nContar = 1 to Len(aConteudo)
          dbSelectArea("ZZ7")
          RecLock("ZZ7",.T.)
          ZZ7_FILIAL := cFilAnt
          ZZ7_CODI   := cNovoCod
          ZZ7_CLIE   := M->A1_COD
          ZZ7_LOJA   := M->A1_LOJA
          ZZ7_DATA   := cData
          ZZ7_HORA   := cHora
          ZZ7_USUA   := Alltrim(Upper(cUserName))
          ZZ7_INDI   := aConteudo[nContar,1]
          ZZ7_RETO	 := aConteudo[nContar,2]
          MsUnLock()

          // ##############################
          // Atualiza a Data de Fundação ##
          // ##############################
    	  If Substr(aConteudo[nContar,2],01,06) == "N20000"
	         _Fundacao := Substr(aConteudo[nContar,2],77,08)

             If !Inclui .And. !Altera
                RecLock("SA1",.F.)
		        SA1->A1_DTNASC  := Ctod(Substr(_Fundacao,01,02) + "/" + Substr(_Fundacao,03,02) + "/" + Substr(_Fundacao,05,04))
		        SA1->A1_DTULTIT := Date()
   		        M->A1_DTNASC    := Ctod(Substr(_Fundacao,01,02) + "/" + Substr(_Fundacao,03,02) + "/" + Substr(_Fundacao,05,04))
		        M->A1_DTULTIT   := Date()
                MsUnlock()
             Else		        
   		        M->A1_DTNASC  := Ctod(Substr(_Fundacao,01,02) + "/" + Substr(_Fundacao,03,02) + "/" + Substr(_Fundacao,05,04))
		        M->A1_DTULTIT := Date()
		     Endif   
	      Endif   

    	  If Substr(aConteudo[nContar,2],01,06)$("N23090#N24090#N25090#N26090#N27090")
             _TTitulos := _TTitulos + INT(VAL(Substr(aConteudo[nContar,2],07,05)))
	      Endif   
                                                
      Next nContar    

      If !Inclui .And. !Altera
         RecLock("SA1",.F.)
         SA1->A1_TITPROT := _TTitulos
         M->A1_TITPROT   := _TTitulos
         MsUnlock()
      Else
         M->A1_TITPROT := _TTitulos
      Endif
      
      // #######################
      // Fecha a janela atual ##
      // #######################
      oDlg:End() 

      // #######################################################################################
      // Chama o programa de consulta de Históricos de Consulta Serasa do Cliente selecionado ##
      // #######################################################################################
      U_AUTOMR44( M->A1_COD, M->A1_LOJA, M->A1_NOME )

   ELSE    

      MsgAlert("Erro no envio da requisição. Tente novamente.")

   ENDIF

   RestArea(aArea)

Return(.T.)