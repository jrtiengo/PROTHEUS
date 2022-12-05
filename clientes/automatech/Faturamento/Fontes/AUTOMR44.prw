#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOMR44.PRW                                                        ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 24/02/2012                                                          ##
// Objetivo..: Visualiza��o historicos de consulta do SERASA                       ##
// Par�metros: < Codigo > - C�digo do Cliente                                      ##
//             < Loja   > - Loja do Cliente                                        ##
//             < Nome   > - Nome do Cliente                                        ##
// Retorno...: .T./.F.                                                             ## 
//**********************************************************************************

User Function AUTOMR44( _Cliente, _Loja, _Nome )

   Local _Ultimo  := .F.
   Local lChumba  := .F.

   Private cCodigo  := _Cliente
   Private cLoja 	:= _Loja
   Private cNomeCli := _Nome

   Private oGet1
   Private oGet2
   Private oGet3

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOMR44")
   
   // #################################################################
   // Verifica se usu�rio tem permiss�o para executar o procedimento ##
   // #################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SERA "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Parametriza��o Serasa inexistente. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   If Empty(Alltrim(T_PARAMETROS->ZZ4_SERA))
      MsgAlert("Parametros de consulta ao Serasa inconsistentes. Contate o Administrador do Sistema.")
      Return .T.
   Endif

   // ###################################################################################
   // Verifica se o usu�rio logado possui autoriza��o para realizar consulta ao Serasa ##
   // ###################################################################################
   If U_P_OCCURS(T_PARAMETROS->ZZ4_SERA, Alltrim(Upper(cUserName)), 1) == 0
      //MsgAlert("Aten��o! Voc� n�o tem permiss�o para executar este procedimento.")
      _Ultimo := .T.
   Else
      _Ultimo := .F.   
   Endif

   // #############################################################
   // Carrega as consultas realizadas para o cliente selecionado ##
   // #############################################################
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
   cSql += " FROM ZZ6010"
   cSql += " WHERE ZZ6_CLIE = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND ZZ6_DELE = ''"

   If _Ultimo
      cSql += " ORDER BY ZZ6_DATA DESC "
   Endif

//   cSql += " UNION "   
//
//   cSql += "SELECT ZZ6_FILIAL, "
//   cSql += "       ZZ6_CODI  , "
//   cSql += "       ZZ6_DATA  , "
//   cSql += "       ZZ6_HORA  , "
//   cSql += "       ZZ6_USUA  , "
//   cSql += "       ZZ6_TIPO  , "
//   cSql += "       ZZ6_CLIE  , "
//   cSql += "       ZZ6_LOJA  , "
//   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_HIST)) AS HISTORICO, "
//   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_POSI)) AS POSICAO  , "
//   cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ6_RETO)) AS RETORNO    "
//   cSql += " FROM ZZ6020"
//   cSql += " WHERE ZZ6_CLIE = '" + Alltrim(cCodigo) + "'"
//   cSql += "   AND ZZ6_DELE = ''"
//
//   If _Ultimo
//      cSql += " ORDER BY ZZ6_DATA DESC "
//   Endif

   cSql += " UNION "   

   cSql += "SELECT ZZ6_FILIAL, "
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
   cSql += " FROM ZZ6030"
   cSql += " WHERE ZZ6_CLIE = '" + Alltrim(cCodigo) + "'"
   cSql += "   AND ZZ6_DELE = ''"

   If _Ultimo
      cSql += " ORDER BY ZZ6_DATA DESC "
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   aBrowse := {}

   If _Ultimo
      aAdd( aBrowse, { Substr(T_SERASA->ZZ6_DATA,07,02) + "/" + ;
                       Substr(T_SERASA->ZZ6_DATA,05,02) + "/" + ;
                       Substr(T_SERASA->ZZ6_DATA,01,04)                 ,;
                       T_SERASA->ZZ6_HORA                               ,;
                       Alltrim(T_SERASA->ZZ6_CODI)                      ,;
                       Alltrim(T_SERASA->ZZ6_USUA)                      ,;
                       IIF(T_SERASA->ZZ6_TIPO == 1, "CREDNET", "RELATO"),;
                       T_SERASA->ZZ6_CLIE                               ,;
                       T_SERASA->ZZ6_LOJA                               })
   Else
      WHILE !T_SERASA->( EOF() )
         aAdd( aBrowse, { Substr(T_SERASA->ZZ6_DATA,07,02) + "/" + ;
                          Substr(T_SERASA->ZZ6_DATA,05,02) + "/" + ;
                          Substr(T_SERASA->ZZ6_DATA,01,04)                 ,;
                          T_SERASA->ZZ6_HORA                               ,;
                          Alltrim(T_SERASA->ZZ6_CODI)                      ,;
                          Alltrim(T_SERASA->ZZ6_USUA)                      ,;
                          IIF(T_SERASA->ZZ6_TIPO == 1, "CREDNET", "RELATO"),;
                          T_SERASA->ZZ6_CLIE                               ,;
                          T_SERASA->ZZ6_LOJA                               })
         T_SERASA->( DbSkip() )
      ENDDO
   Endif   

   If Len(aBrowse) == 0
      aAdd( aBrowse, { '', '', '', '', '', '', '' } )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Hist�rico de Consulta SERASA" FROM C(178),C(181) TO C(624),C(631) PIXEL

   @ C(005),C(005) Say "Cliente"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Consultas Realizadas" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1      Var cCodigo  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
   @ C(014),C(031) MsGet    oGet2      Var cLoja    When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
   @ C(014),C(050) MsGet    oGet3      Var cNomeCli When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
// @ C(027),C(140) CheckBox oCheckBox1 Var lTodas   Prompt "Consultar Todas as Lojas do Cliente" Size C(097),C(008) PIXEL OF oDlg

   @ C(208),C(005) Button "Visualizar Consulta" Size C(059),C(012) PIXEL OF oDlg ACTION( ARV_SERASA( aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ], aBrowse[ oBrowse:nAt, 05 ] ) )
   @ C(208),C(070) Button "Relat�rio"           Size C(059),C(012) PIXEL OF oDlg ACTION( REL_SERASA( aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ], aBrowse[ oBrowse:nAt, 05 ] ) )
   @ C(208),C(183) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TSBrowse():New(045,005,277,215,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Data'         ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Hora'         ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('C�digo'       ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Usu�rio'      ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Tipo Consulta',,,{|| },{|| }) )      
   oBrowse:AddColumn( TCColumn():New('Cod.Cli'      ,,,{|| },{|| }) )      
   oBrowse:AddColumn( TCColumn():New('Loja'         ,,,{|| },{|| }) )         
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##########################################################################
// Fun��o que pesquisa o hist�rico quando duplo click � utilizado na lista ##
// ##########################################################################
Static Function ARV_SERASA(_Data, _Hora, _Codigo, _Usuario, _Tipo)

   // #############################
   // Variaveis Locais da Funcao ##
   // #############################
   Local lChumba   := .F.
   Local _xCliente := cCodigo
   Local _xLoja    := cLoja
   Local _xNome    := cNomeCli
   Local _xData    := _data
   Local _xHora    := _Hora
   Local _xUsuario := _Usuario
   Local _xTipo    := _Tipo

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7

   Private cSql         := ""
   Private lChumba      := .F.
   Private nContar      := 0
   Private lExiste      := .F.
   Private nContar      := 0
   Private nNivel1      := 0
   Private nNivel2      := 0
   Private cCargo       := 0
   Private nAcha        := 0
   Private nMostra      := 0
   Private cBmp1        := "PMSEDT3" 
   Private cBmp2        := "PMSDOC" 
   Private aPosicao := {}

   // ########################################
   // Posicionamentos e T�tulos da Consulta ##
   // ########################################
   aAdd( aPosicao, { "N20000", "", "Dados Cadastrais"                   , "07,70|77,08|85,02|87,08|95,21|"                                     , "Raz�o Social|Data Nascimento/Funda��o|Situa��o CPF/CNPJ|Data Situa��o CPF/CNPJ|Reservado|" } )
   aAdd( aPosicao, { "N20001", "", "Dados Cadastrais"                   , "07,40|47,69|"                                                       , "Nome M�e do CPF|Reservado|" } )
   aAdd( aPosicao, { "N21000", "", "Alerta de Documentos Roubados"      , "07,02|09,02|11,06|17,20|37,04|41,10|51,59|"                         , "N� da mensagem|Total de mensagens|Tipo de Documento|N� do Documento|Motivo da Ocorr�ncia|Data da Ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N21001", "", "Alerta de Documentos Roubados"      , "07,03|10,08|18,03|21,08|29,03|32,08|40,76|"                         , "C�digo DDD 1|N� do Telefone 1|C�digo DDD 2|N� do Telefone 2|C�digo DDD3|N� do Telefone 3|Reservado|" } )
   aAdd( aPosicao, { "N21099", "", "Alerta de Documentos Roubados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N22000", "", "Nada Consta"                        , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N23000", "", "Pend�ncia Interna / Pefin de Grupo" , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114|02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N23090", "", "Pend�ncia Interna / Pefin de Grupo" , "07,05|12,06|18,06|24,15|39,77|"                                     , "Total de Ocorr�ncias|Data da Ocorr�ncia mais antiga|Data da Ocorr~encia mais recente|Valor total das Pend�ncias Internas|Reservado|"} )
   aAdd( aPosicao, { "N23099", "", "Pend�ncia Interna / Pefin de Grupo" , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N24000", "", "Pend�ncia Financeira"               , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114,02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N24001", "", "Pend�ncia Financeira"               , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N24090", "", "Pend�ncia Financeira"               , "07,05|12,06|18,06|24,15|39,01|40,76|"                               , "Total de Ocorr�ncias|Data da ocorr�ncia mais antiga|Data da ocorr�ncia mais recente|Valor total das Pend�ncias Financeiras|Tipo de anota��o|Reservado|" } )
   aAdd( aPosicao, { "N24099", "", "Pend�ncia Financeira"               , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N25000", "", "Protesto Estadual / Nacional"       , "07,08|15,03|18,15|33,02|35,30|65,02|78,38|"                         , "Data da Ocorr�ncia|Tipo de Moeda|Valor|Cart�rio|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N25001", "", "Protesto Estadual / Nacional"       , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
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
   aAdd( aPosicao, { "N62000", "", "Limite de Cr�dito PJ"               , "07,13|"                                                             , "Valor Limite de Cr�dito Pessoa Jur�dica|" } ) 
   aAdd( aPosicao, { "N62090", "", "Observa��es Limite de Cr�dito PJ"   , "07,79|"                                                             , "|" } )
   aAdd( aPosicao, { "B3702" , "", "Limite de Cr�dito PF"               , "124,09|"                                                            , "Limite de Cr�dito PF|" } )
   
   Private oDlgD

   DEFINE MSDIALOG oDlgD TITLE "Hist�rico de Consulta SERASA" FROM C(178),C(181) TO C(619),C(857) PIXEL

   @ C(005),C(005) Say "Cliente"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(005) Say "Data da Consulta"                 Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(052) Say "Hora da Consulta"                 Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(101) Say "Usu�rio que realizaou a consulta" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(047),C(005) Say "Detalhes da Consulta"             Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(185) Say "Tipo de Consulta"                 Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(014),C(005) MsGet oGet1 Var _xCliente  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(014),C(031) MsGet oGet2 Var _xLoja     When lChumba Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(014),C(050) MsGet oGet3 Var _xNome     When lChumba Size C(242),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(036),C(005) MsGet oGet4 Var _xData     When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(036),C(052) MsGet oGet5 Var _xHora     When lChumba Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(036),C(101) MsGet oGet6 Var _xUsuario  When lChumba Size C(078),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   @ C(036),C(185) MsGet oGet7 Var _xTipo     When lChumba Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
	
   @ C(012),C(296) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   // #########################
   // Cria o Objeto TreeView ##
   // #########################
   oTree := DbTree():New(070,005,275,423,oDlgD,,,.T.)

   // #################################################
   // Pesquisa os dados para elabora��o do tree view ##
   // #################################################
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT ZZ7_FILIAL,"
   cSql += "                ZZ7_CODI  ,"
   cSql += "                SUBSTRING(ZZ7_INDI,01,04) AS INDICE "
   cSql += "  FROM " + RetSqlName("ZZ7")
   cSql += " WHERE ZZ7_CODI = '" + Alltrim(_Codigo) + "'"
   cSql += " GROUP BY ZZ7_FILIAL, ZZ7_CODI, SUBSTRING(ZZ7_INDI,01,04)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   T_SERASA->( DbGoTop() )

   nNivel1 := 1
   nNivel2 := 100

   // ########################################
   // Abre o n�vel mais elevado do TreeView ##
   // ########################################
   oTree:AddItem("HIST�RICO DA CONSULTA AO SERASA" + Space(84), Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

   cCargo  := 1

   WHILE !T_SERASA->( EOF() )

      // ##############################################
      // Pesquisa o nome do t�tulo a ser apresentado ##
      // ##############################################
      For nContar = 1 to Len(aPosicao)
          If Substr(aPosicao[nContar,1],01,04) == Alltrim(T_SERASA->INDICE)
             Exit
          Endif
      Next nContar       

      nNivel1 += 1
      nNivel2 := nNivel2 + 100

      // ##########################
      // Cria a Linha do Projeto ##
      // ##########################
      oTree:AddItem("[ " + UPPER(aPosicao[nContar,3]) + " ]", Strzero(nNivel1,3), cBmp1 ,,,,nNivel2)

      // ##########################################################
      // Pesquisa os dados a serem listados abaixo do sub-t�tulo ##
      // ##########################################################
      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT ZZ7_FILIAL,"
      cSql += "       ZZ7_CODI  ,"
      cSql += "       ZZ7_INDI  ,"
      cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ7_RETO)) AS HISTORICO"
      cSql += "  FROM " + RetSqlName("ZZ7")
      cSql += " WHERE ZZ7_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND SUBSTRING(ZZ7_INDI,01,04) = '" + Alltrim(T_SERASA->INDICE) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

      T_DETALHE->( DbGoTop() )
      
      WHILE !T_DETALHE->( EOF() )
      
          // ################################################################
          // Localiza o cabe�alho e posicionamento dos campos para display ##
          // ################################################################
          For nAcha = 1 to Len(aPosicao)
              If aPosicao[nAcha,1] == Alltrim(T_DETALHE->ZZ7_INDI)
                 Exit
              Endif
          Next nAcha

          For nMostra = 1 to U_P_OCCURS(aPosicao[nAcha,5], "|", 1)

              If Alltrim(UPPER(U_P_CORTA(aPosicao[nAcha,5], "|", nMostra))) == "RESERVADO"
                 Loop
              Endif   

              nNivel2 += 1

              _Titulo     := U_P_CORTA(aPosicao[nAcha,5], "|", nMostra)
              _Coordenada := U_P_CORTA(aPosicao[nAcha,4], "|", nMostra) + ","
              _Inicial    := INT(VAL(U_P_CORTA(_Coordenada, ",", 1)))
              _Final      := INT(VAL(U_P_CORTA(_Coordenada, ",", 2)))
              _Conteudo   := Substr(T_DETALHE->HISTORICO, _Inicial, _Final)

              // ####################################
              // Identifica a Situa��o do CPF/CNPJ ##
              // ####################################
              If _Titulo == "Situa��o CPF/CNPJ"
                 Do Case
                    Case Alltrim(_Conteudo) == "2"
                         _Conteudo := _Conteudo + " - REGULAR"
                    Case Alltrim(_Conteudo) == "3"
                         _Conteudo := _Conteudo + " - PENDENTE DE REGULARIZA��O"
                    Case Alltrim(_Conteudo) == "6"
                         _Conteudo := _Conteudo + " - SUSPENSA"
                    Case Alltrim(_Conteudo) == "9"
                         _Conteudo := _Conteudo + " - CANCELADA"
                    Case Alltrim(_Conteudo) == "4"
                         _Conteudo := _Conteudo + " - NULA"
                  EndCase                         
              ENDIF

              // ##############################
              // Identifica o campo Avalista ##
              // ##############################
              If _Titulo == "Avalista"
                 If Alltrim(_Conteudo) == "S"
                    _Conteudo := _Conteudo + " - Avalista"        
                 Else
                    _Conteudo := _Conteudo + " - N�o � Avalista"                            
                 Endif
              Endif

              // ##############################
              // Identifica Tipo de Anota��o ##
              // ##############################
              If _Titulo == "Tipo de anota��o"
                 Do Case
                    Case Alltrim(_Conteudo) == "V"
                         _Conteudo := _Conteudo + " - Pefin"
                    Case Alltrim(_Conteudo) == "I"
                         _Conteudo := _Conteudo + " - Refin"
                    Case Alltrim(_Conteudo) == "5"
                         _Conteudo := _Conteudo + " - D�vida Vencida"
                 EndCase
              Endif           

              // #####################################################################
              // Varifica se � um campo data. Se for, converte para data DD/MM/AAAA ##
              // #####################################################################
              If U_P_OCCURS(_Titulo, "Data", 1) <> 0
                 If Len(Alltrim(_Conteudo)) == 6
                    _Conteudo := Substr(_Conteudo,01,02) + "/" + Substr(_Conteudo,03,04)
                 Else
                    _Conteudo := Substr(_Conteudo,01,02) + "/" + Substr(_Conteudo,03,02) + "/" + Substr(_Conteudo,05,04)
                 Endif   
              Endif

              If U_P_OCCURS(_Titulo, "Valor", 1) <> 0
                 _Conteudo := ALLTRIM(STR(VAL(SUBSTR(_Conteudo,1,13) + "." + SUBSTR(_Conteudo,14,02)),15,02))
              Endif
              
              oTree:AddItem(">      " + Alltrim(_Titulo) + ": " + Alltrim(_Conteudo), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)

              cCargo += 1
              
          Next nMostra    

          nNivel2 += 1

          oTree:AddItem(Replicate("-", 500), "cCargo" + Strzero(cCargo,3), ,,,,nNivel2)

          cCargo += 1

          T_DETALHE->( DbSkip() )
          
      ENDDO

      T_SERASA->( DbSkip() )
      
   ENDDO

   // ############################ 
   // Retorna ao primeiro n�vel ##
   // ############################
   oTree:TreeSeek("001")

   // #########################################
   // Indica o t�rmino da constru��o da Tree ##
   // #########################################
   oTree:EndTree()


   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)

// ###################################################################
// Fun��o que imprime o relat�rio da consulta do SERASA selecionada ##
// ###################################################################
Static Function REL_SERASA(_Data, _Hora, _Codigo, _Usuario, _Tipo)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""
   Local nGeral     := 0
   Local cTexto     := ""

   Local nPoaInt    := 0
   Local nCxsInt    := 0
   Local nPelInt    := 0
   Local nPoaExt    := 0
   Local nCxsExt    := 0
   Local nPelExt    := 0
   Local lPrimeiro  := .T.
   Local cCabeca    := ""
   Local _Cabeca    := 0

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 3000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   Private aPosicao := {}

   // ########################################
   // Posicionamentos e T�tulos da Consulta ##
   // ########################################
   aAdd( aPosicao, { "N20000", "", "Dados Cadastrais"                   , "07,70|77,08|85,02|87,08|95,21|"                                     , "Raz�o Social|Data Nascimento/Funda��o|Situa��o CPF/CNPJ|Data Situa��o CPF/CNPJ|Reservado|" } )
   aAdd( aPosicao, { "N20001", "", "Dados Cadastrais"                   , "07,40|47,69|"                                                       , "Nome M�e do CPF|Reservado|" } )
   aAdd( aPosicao, { "N21000", "", "Alerta de Documentos Roubados"      , "07,02|09,02|11,06|17,20|37,04|41,10|51,59|"                         , "N� da mensagem|Total de mensagens|Tipo de Documento|N� do Documento|Motivo da Ocorr�ncia|Data da Ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N21001", "", "Alerta de Documentos Roubados"      , "07,03|10,08|18,03|21,08|29,03|32,08|40,76|"                         , "C�digo DDD 1|N� do Telefone 1|C�digo DDD 2|N� do Telefone 2|C�digo DDD3|N� do Telefone 3|Reservado|" } )
   aAdd( aPosicao, { "N21099", "", "Alerta de Documentos Roubados"      , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N22000", "", "Nada Consta"                        , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N23000", "", "Pend�ncia Interna / Pefin de Grupo" , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114|02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N23090", "", "Pend�ncia Interna / Pefin de Grupo" , "07,05|12,06|18,06|24,15|39,77|"                                     , "Total de Ocorr�ncias|Data da Ocorr�ncia mais antiga|Data da Ocorr~encia mais recente|Valor total das Pend�ncias Internas|Reservado|"} )
   aAdd( aPosicao, { "N23099", "", "Pend�ncia Interna / Pefin de Grupo" , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N24000", "", "Pend�ncia Financeira"               , "07,08|15,30|45,01|46,03|49,15|64,16|80,30|110,04|114,02|"           , "Data da Ocorr�ncia|Modalidade|Avalista|Tipo de Moeda|Valor|Contrato|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N24001", "", "Pend�ncia Financeira"               , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
   aAdd( aPosicao, { "N24090", "", "Pend�ncia Financeira"               , "07,05|12,06|18,06|24,15|39,01|40,76|"                               , "Total de Ocorr�ncias|Data da ocorr�ncia mais antiga|Data da ocorr�ncia mais recente|Valor total das Pend�ncias Financeiras|Tipo de anota��o|Reservado|" } )
   aAdd( aPosicao, { "N24099", "", "Pend�ncia Financeira"               , "07,40|47,69|"                                                       , "Mensagem|Reservado|" } )
   aAdd( aPosicao, { "N25000", "", "Protesto Estadual / Nacional"       , "07,08|15,03|18,15|33,02|35,30|65,02|78,38|"                         , "Data da Ocorr�ncia|Tipo de Moeda|Valor|Cart�rio|Origem|Sigla Embratel da pra�a da ocorr�ncia|Reservado|" } )
   aAdd( aPosicao, { "N25001", "", "Protesto Estadual / Nacional"       , "07,01|08,76|84,01|85,10|95,21|"                                     , "Indica anota��o Subj�dice|Mensagem Subj�dice|Tipo de anota��o|C�digo do Cadus para pesquisa de Zoom|Reservado|" } )
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
   aAdd( aPosicao, { "N62000", "", "Limite de Cr�dito PJ"               , "07,13|"                                                             , "Valor Limite de Cr�dito Pessoa Jur�dica|" } ) 
   aAdd( aPosicao, { "N62090", "", "Observa��es Limite de Cr�dito PJ"   , "07,79|"                                                             , "|" } )
   aAdd( aPosicao, { "B3702" , "", "Limite de Cr�dito PF"               , "124,09|"                                                            , "Limite de Cr�dito PF|" } )
  
   // #############################
   // Cria o objeto de impressao ##
   // #############################
   oPrint := TmsPrinter():New()
// oPrint:SetLandScape()  // Para Paisagem
   oPrint:SetPortrait()    // Para Retrato
   oPrint:SetPaperSize(9) // A4
	
   // ###########################################################################
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio ##
   // ###########################################################################
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
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

   // ######################################
   // Pesquisa os dados a serem impressos ##
   // ######################################
   If Select("T_SERASA") > 0
      T_SERASA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT ZZ7_FILIAL,"
   cSql += "                ZZ7_CODI  ,"
   cSql += "                SUBSTRING(ZZ7_INDI,01,04) AS INDICE "
   cSql += "  FROM " + RetSqlName("ZZ7")
   cSql += " WHERE ZZ7_CODI = '" + Alltrim(_Codigo) + "'"
   cSql += " GROUP BY ZZ7_FILIAL, ZZ7_CODI, SUBSTRING(ZZ7_INDI,01,04)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERASA", .T., .T. )

   T_SERASA->( DbGoTop() )

   // ###########################################
   // Inicializa linha e p�gina para impress�o ##
   // ###########################################
   nPagina  := 0
   _nLin    := 10
      
   // ###########################################################
   // Envia para a fun��o que imprime o cabe�alho do relat�rio ##
   // ###########################################################
   CABSERASA(_Data, _Hora, _Codigo, _Usuario, _Tipo)

   WHILE !T_SERASA->( EOF() )

      // ##############################################
      // Pesquisa o nome do t�tulo a ser apresentado ##
      // ##############################################
      For nContar = 1 to Len(aPosicao)
          If Substr(aPosicao[nContar,1],01,04) == Alltrim(T_SERASA->INDICE)
             Exit
          Endif
      Next nContar       

      cTexto := "[ " + UPPER(aPosicao[nContar,3]) + " ]"

      oPrint:Say( _nLin, 0100, cTexto, oFont21)  
      SomaLinhaSer(60, _Data, _Hora, _Codigo, _Usuario, _Tipo)

      // ##########################################################
      // Pesquisa os dados a serem listados abaixo do sub-t�tulo ##
      // ##########################################################
      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT ZZ7_FILIAL,"
      cSql += "       ZZ7_CODI  ,"
      cSql += "       ZZ7_INDI  ,"
      cSql += "       CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ7_RETO)) AS HISTORICO"
      cSql += "  FROM " + RetSqlName("ZZ7")
      cSql += " WHERE ZZ7_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND SUBSTRING(ZZ7_INDI,01,04) = '" + Alltrim(T_SERASA->INDICE) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

      T_DETALHE->( DbGoTop() )
      
      WHILE !T_DETALHE->( EOF() )
      
          // ################################################################
          // Localiza o cabe�alho e posicionamento dos campos para display ##
          // ################################################################
          For nAcha = 1 to Len(aPosicao)
              If aPosicao[nAcha,1] == Alltrim(T_DETALHE->ZZ7_INDI)
                 Exit
              Endif
          Next nAcha
                       
          lPrimeiro := .T.
          cCabeca   := ""
          cTexto    := ""

          For nMostra = 1 to U_P_OCCURS(aPosicao[nAcha,5], "|", 1)

              If Alltrim(UPPER(U_P_CORTA(aPosicao[nAcha,5], "|", nMostra))) == "RESERVADO"
                 Loop
              Endif   

              _Titulo     := U_P_CORTA(aPosicao[nAcha,5], "|", nMostra)
              _Coordenada := U_P_CORTA(aPosicao[nAcha,4], "|", nMostra) + ","
              _Inicial    := INT(VAL(U_P_CORTA(_Coordenada, ",", 1)))
              _Final      := INT(VAL(U_P_CORTA(_Coordenada, ",", 2)))
              _Conteudo   := Substr(T_DETALHE->HISTORICO, _Inicial, _Final)

              // ##################################################################### 
              // Varifica se � um campo data. Se for, converte para data DD/MM/AAAA ##
              // #####################################################################
              If U_P_OCCURS(_Titulo, "Data", 1) <> 0
                 _Conteudo := Substr(_Conteudo,01,02) + "/" + Substr(_Conteudo,03,02) + "/" + Substr(_Conteudo,05,04)
              Endif

              If U_P_OCCURS(_Titulo, "Valor", 1) <> 0
                 _Conteudo := ALLTRIM(STR(VAL(SUBSTR(_Conteudo,1,13) + "." + SUBSTR(_Conteudo,14,02)),15,02))
              Endif
              
              cTexto := ""
              cTexto += _Titulo + ": " + _Conteudo

              oPrint:Say( _nLin, 0100, cTexto, oFont21)  
              SomaLinhaSer(40, _Data, _Hora, _Codigo, _Usuario, _Tipo)

          Next nMostra    

          SomaLinhaSer(40, _Data, _Hora, _Codigo, _Usuario, _Tipo)
          oPrint:Line( _nLin, 0100, _nLin, 3350 )
          SomaLinhaSer(40, _Data, _Hora, _Codigo, _Usuario, _Tipo)

          T_DETALHE->( DbSkip() )

      ENDDO

      T_SERASA->( DbSkip() )
      
   ENDDO

// oPrint:EndPage()

 oPrint:Preview()
   
   MS_FLUSH()

Return .T.

// ###################################
// Imprime o cabe�alho do relat�rio ##
// ###################################
Static Function CABSERASA(_Data, _Hora, _Codigo, _Usuario, _Tipo)

   Local cTexto := ""

   oPrint:StartPage()
   nPagina := nPagina + 1
   _nLin   := 60
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMA��O LTDA", oFont21)
   oPrint:Say( _nLin, 0950, "HIST�RICO CONSULTA SERASA EXPIRIAN"   , oFont21)
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()            , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOMR44.PRW", oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   // #################################
   // Elabora a Linha para impress�o ##
   // #################################
   cTexto := "Data Consulta: " + _Data + "                              C�digo Consulta: " + _Codigo + "                              Tipo: " + Alltrim(_Tipo)
   oPrint:Say( _nLin, 0100, cTexto, oFont21)  
   _nLin += 50

   cTexto := "Hora Consulta: " + _Hora + "                                Usu�rio........: " + Alltrim(_Usuario)
   oPrint:Say( _nLin, 0100, cTexto, oFont21)  
   
   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50

Return .T.

// ########################################
// Fun��o que soma linhas para impress�o ##
// ########################################
Static Function SomaLinhaSer(nLinhas, _Data, _Hora, _Codigo, _Usuario, _Tipo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABSERASA(_Data, _Hora, _Codigo, _Usuario, _Tipo)
   Endif
   
Return .T.