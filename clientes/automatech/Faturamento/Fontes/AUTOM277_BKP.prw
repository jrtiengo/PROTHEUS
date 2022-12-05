#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//********************************************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                                                 *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Referencia: AUTOM277.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 07/01/2016                                                                                                                                *
// Objetivo..: Programa que realiza a verificação dos discionários de dados do Protheus.                                                                 *
//********************************************************************************************************************************************************

User Function AUTOM277()

   Local cMemo1	 := ""
   Local oMemo1

   Private aOrigem    := {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech", "04 - AtechPel"}
   Private aDestino   := {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech", "04 - AtechPel"}
   Private aArquivos  := {"000 - Selecione"                        ,;
                          "SX1 – Perguntas e respostas"            ,;
                          "SX2 – Mapeamento de arquivos"           ,;
                          "SX3 – Dicionário de dados"              ,;
                          "SX4 – Agenda Schedule processos"        ,;
                          "SX5 – Tabelas"                          ,;
                          "SX6 – Parâmetros"                       ,;
                          "SX7 – Gatilhos"                         ,;
                          "SX9 – Relacionamento entre arquivos"    ,;
                          "SXA – Pastas cadastrais"                ,;
                          "SXB – Consulta padrão"                  ,;
                          "SXC – Controle de usuários"             ,;
                          "SXD – Controle de Schedule de processos",;
                          "SXE – Seq. de doc (+1, END)"            ,;
                          "SXF – Seq. de doc (próximo, FIRST)"     ,;
                          "SXG – Tamanho padrão para campos"       ,;
                          "SXK – Controle perguntas (SX1) usuários",;
                          "SXO – Controle log’s por tabela"        ,;
                          "SXP – Controle log’s por tabela"        ,;
                          "SIX – Índices dos arquivos (1)"          }

   Private cOrigem   
   Private cDestino  
   Private cArquivos 

   Private cResultado := ""
   Private oMemo2

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlg

   Private aLista := {}
   Private oLista

   DEFINE MSDIALOG oDlg TITLE "Verificador Dicionário de Dados" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Dicionário de Dados Modelo"             Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(100) Say "Resultado da Verificação"               Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Dicionário de Dados a ser comparado"    Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(084),C(005) Say "Arquivo do dicionário a ser verificado" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(108),C(005) Say "Estrutura do Diconário Selecionado"     Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(047),C(005) ComboBox cOrigem   Items aOrigem          Size C(091),C(010) PIXEL OF oDlg
   @ C(070),C(005) ComboBox cDestino  Items aDestino         Size C(091),C(010) PIXEL OF oDlg
   @ C(095),C(005) ComboBox cArquivos Items aArquivos        Size C(091),C(010) PIXEL OF oDlg on change CargaEstrtura()
   @ C(047),C(100) GET      oMemo2    Var   cResultado  MEMO Size C(395),C(175) PIXEL OF oDlg

   @ C(210),C(005) Button "M"         Size C(011),C(012) PIXEL OF oDlg ACTION( MrcCampo(1) )
   @ C(210),C(017) Button "D"         Size C(011),C(012) PIXEL OF oDlg ACTION( MrcCampo(2) )
   @ C(210),C(030) Button "PA"        Size C(011),C(012) PIXEL OF oDlg
   @ C(210),C(044) Button "Verificar" Size C(025),C(012) PIXEL OF oDlg
   @ C(210),C(070) Button "Voltar"    Size C(025),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "" })

   @ 150,005 LISTBOX oLista FIELDS HEADER "M", "Descrição" PIXEL SIZE 115,113 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )
   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),;
                           aLista[oLista:nAt,02]         }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###################################################################
// Função que carrega aLista com a estritura do arquivo selecionado ##
// ###################################################################
Static Function CargaEstrtura()

   Local nContar    := 0
   Local cTabela    := ""
   Local cEstrutura := ""
 
   If Substr(cArquivos,01,03) == "000"
      Return(.T.)
   Endif

   cTabela := Substr(cArquivos,01,03) + Substr(cOrigem,01,02) + "0.DTC"  

   dbUseArea(.T., , (cTabela), "ESTRUTURA", .T., .F.)

   aLista := {}
   
   For nContar = 1 to 1000
       If TYPE(FIELD(nContar)) == "U"
          Loop
       Endif   
       aAdd( aLista, { .F., FIELD(nContar) } ) 
   Next nContar    

   dbCloseArea()
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "" })
   Endif
       
   oLista:SetArray( aLista )
   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo), aLista[oLista:nAt,02] }}
   oLista:Refresh()

Return(.T.)

// ###########################################
// Função que marca/desmarca o array aLista ##
// ###########################################
Static Function MrcCampo( kTipo )

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF( kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       
   


// Função que realiza a verificação dos discionários conforme parâmetros informados
Static Function xRodaVerificao()


   Local cMemo1	 := ""
   Local cMemo3	 := ""
   Local oMemo1
   Local oMemo3

   Private aOrigem   := {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private aDestino  := {"00 - Selecione", "01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private aArquivos := {"00 - Selecione o discionários a ser verificado", "01 - Tabelas do Discionário", "02 - Campos do Discionário"}
   Private aVisual   := {"00 - Selecione", "01 - Registros OK", "02 - Registros NÃO OK", "03 - Ambos"}

   Private cOrigem
   Private cDestino
   Private cArquivos
   Private cVisual

   Private oDlgP

   DEFINE MSDIALOG oDlgP TITLE "Verificador Discionário de Dados" FROM C(178),C(181) TO C(507),C(524) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlgP

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(164),C(001) PIXEL OF oDlgP
   @ C(139),C(003) GET oMemo3 Var cMemo3 MEMO Size C(164),C(001) PIXEL OF oDlgP

   @ C(044),C(007) Say "Discionário de Dados da Empresa (BASE)"            Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(067),C(007) Say "Discionário de Dados da Empresa (A ser comparado)" Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(090),C(007) Say "Arquivo a ser verificado"                          Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(114),C(007) Say "Resultado a ser visualizado"                       Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
      
   @ C(054),C(007) ComboBox cOrigem   Items aOrigem   Size C(157),C(010) PIXEL OF oDlgP
   @ C(077),C(007) ComboBox cDestino  Items aDestino  Size C(157),C(010) PIXEL OF oDlgP
   @ C(101),C(007) ComboBox cArquivos Items aArquivos Size C(157),C(010) PIXEL OF oDlgP
   @ C(124),C(007) ComboBox cVisual   Items aVisual   Size C(157),C(010) PIXEL OF oDlgP

   @ C(147),C(005) Button "Copy Structure" Size C(047),C(012) PIXEL OF oDlgP ACTION( CopiaEstru() )
   @ C(147),C(047) Button "Verificar" Size C(037),C(012) PIXEL OF oDlgP ACTION( RodaVerificao() )
   @ C(147),C(088) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que realiza a verificação dos discionários conforme parâmetros informados
Static Function CopiaEstru()

   Local _Estrutura := ""

   dbUseArea(.T., , "SX2010.DTC", "DBF_ORIGEM", .T., .F.)

   Copy structure to &_Estrutura
   DbUseArea(.t.,,_Estrutura,"TRB2",.f.,.f.)
   dbSelectArea("TRB2")   
   
   
Return(.T.)   

// Função que realiza a verificação dos discionários conforme parâmetros informados
Static Function RodaVerificao()

   Local lChumba := .F.
   
   Local cMemo1	 := ""
   Local oMemo1

   Private cResultado := ""
   Private oResultado

   Private nTotRegistros := 0
   Private nTotRegOK     := 0
   Private nTotRegNOK    := 0
   Private nTotRegAgen   := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   
   // Declara as Legendas
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

   Private aBrowse   := {}

   Private oDlg

   // Realiza consistências dos dados antes de executar a pesquisa
   If Substr(cOrigem,01,02) == "00" 
      Msgalert("Discionário de Dados da Empresa Base não informado.")
      Return(.T.)
   Endif
      
   If Substr(cDestino,01,02) == "00" 
      Msgalert("Discionário de Dados da Empresa a ser comparada não informado.")
      Return(.T.)
   Endif

   If Substr(cOrigem,01,02) == Substr(cDestino,01,02)
      Msgalert("Discionário de Dados da Empresa Base não pode ser igual ao Discionário de Dados da Empresa a ser verificada.")
      Return(.T.)
   Endif

   If Substr(cArquivos,01,02) == "00" 
      Msgalert("Arquivo a ser comparado não informado.")
      Return(.T.)
   Endif

   If Substr(cVisual,01,02) == "00" 
      Msgalert("Tipo de Visualização de resultado não selecionado.")
      Return(.T.)
   Endif

   // Dispara a pesquisa para display
   VerificaDiscionario()

   // Desenha a tela para visualização dos resultados
   DEFINE MSDIALOG oDlg TITLE "Verificador Discionário de Dados" FROM C(178),C(181) TO C(639),C(1180) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"  Size C(126),C(026) PIXEL NOBORDER OF oDlg
   @ C(219),C(094) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(219),C(185) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(219),C(280) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
                 
   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(496),C(001) PIXEL OF oDlg

   @ C(038),C(067) Say "Disc. Empresa a Verificar"         Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(005) Say "Disc. Empresa Base"                Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(132) Say "Verificar o Arquivo do Dicionário" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(039),C(282) Say "Visualizar"                        Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(063),C(005) Say "Resultado da Verificação"          Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(218),C(028) Say "Total Registros"                   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(218),C(107) Say "Total Registros OK"                Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(218),C(198) Say "Total Registros NÃO OK"            Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(218),C(293) Say "Total Registros Agendados"         Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(049),C(005) ComboBox cOrigem   Items aOrigem   Size C(056),C(010) PIXEL OF oDlg When lChumba
   @ C(049),C(066) ComboBox cDestino  Items aDestino  Size C(056),C(010) PIXEL OF oDlg When lChumba
   @ C(049),C(132) ComboBox cArquivos Items aArquivos Size C(143),C(010) PIXEL OF oDlg When lChumba
   @ C(049),C(282) ComboBox cVisual   Items aVisual   Size C(106),C(010) PIXEL OF oDlg When lChumba

   @ C(216),C(005) MsGet oGet1 Var nTotRegistros Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(216),C(071) MsGet oGet2 Var nTotRegOK     Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(216),C(158) MsGet oGet3 Var nTotRegNOK    Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(216),C(255) MsGet oGet4 Var nTotRegAgen   Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   // Abre o grid para visualização
   If Substr(cArquivos,01,02) == "01"

      oBrowse := TCBrowse():New( 092 , 005, 630, 177,,{''                             ,; // 01 - Legenda (Verde - OK, Vermelho - Com Inconsistência)
                                                       'Tabela'                       ,; // 02 - Nome da Tabela
                                                       'Descrição Tabela' + Space(80) ,; // 03 - Descrição da Tabela
                                                       'Observações'      + Space(70) ,; // 04 - Observações
                                                       'Status'           + Space(40)},; // 05 - Status
                                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   Else

      oBrowse := TCBrowse():New( 092 , 005, 630, 177,,{''                               ,; // 01 - Legenda (Verde - OK, Vermelho - Com Inconsistência)
                                                       'Tabela'                         ,; // 02 - Nome da Tabela
                                                       'Descrição Tabela'   + Space(80) ,; // 03 - Descrição da Tabela
                                                       'Campo'              + Space(30) ,; // 04 - Nome do Campo
                                                       'Descrição do Campo' + Space(30) ,; // 05 - Descrição do Campo
                                                       'Tipo'               + Space(15) ,; // 06 - Tipo de Campo
                                                       'Tamanho'            + Space(15) ,; // 07 - Tamanho do Campo
                                                       'Decimal'            + Space(15) ,; // 08 - Decimal do Campo
                                                       'Observações'        + Space(70) ,; // 09 - Observações
                                                       'Status'             + Space(40)},; // 10 - Status
                                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   Endif                                                         

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      If Substr(cArquivos,01,02) == "01"
         oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                               aBrowse[oBrowse:nAt,02]               ,;
                               aBrowse[oBrowse:nAt,03]               ,;
                               aBrowse[oBrowse:nAt,04]               ,;
                               aBrowse[oBrowse:nAt,05]               }}
      Else
         oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                               If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                               aBrowse[oBrowse:nAt,02]               ,;
                               aBrowse[oBrowse:nAt,03]               ,;
                               aBrowse[oBrowse:nAt,04]               ,;
                               aBrowse[oBrowse:nAt,05]               ,; 
                               aBrowse[oBrowse:nAt,06]               ,; 
                               aBrowse[oBrowse:nAt,07]               ,; 
                               aBrowse[oBrowse:nAt,08]               ,; 
                               aBrowse[oBrowse:nAt,09]               ,; 
                               aBrowse[oBrowse:nAt,10]               }}
      Endif                                     
   Endif   

   @ C(214),C(371) Button "Gera CFGLOG.DTC" Size C(058),C(012) PIXEL OF oDlg ACTION( AgendaCFGLOG() )
   @ C(214),C(430) Button "Gera TXT"        Size C(029),C(012) PIXEL OF oDlg ACTION( GeraTXTResult() )
   @ C(214),C(460) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a verificação dos discionários conforme parâmetros informados
Static Function VerificaDiscionario()

   // Pode ser colocado aqui alguma verificação se necessário

   // Chama a função de verificação de estrutura
   GeraVerificacao()

Return(.T.)

// Função que pesquisa produtos conforme parâmetros informados
Static Function GeraVerificacao()

  MsgRun("Favor Aguarde! Verificando Estrutura ...", "Verificando Estrutura",{|| GrVerificacao() })

Return(.T.)

// Função que pesquisa produtos conforme parâmetros informados
Static Function GrVerificacao()

   Local cSql       := ""
   Local lExiste    := .F.
   Local nContarOri := 0
   Local nContarDes := 0
   Local xArquivo   := ""

   Private aTransito   := {}
   Private aEstOrigem  := {}
   Private aEstDestino := {}

   // Alimenta o array aEstOrigem com os campos da tabela selecionada
   Do Case

      Case Substr(cOrigem,01,02) == "01"

           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2010.DBF", "DBF_ORIGEM", .T., .F.)
              dbUseArea(.T., , "SX2010.DTC", "DBF_ORIGEM", .T., .F.)
           Else
//              dbUseArea(.T., "DBFCDX", "SX2010.DBF", "DBF_TABELA", .T., .F.)
//              dbUseArea(.T., "DBFCDX", "SX3010.DBF", "DBF_ORIGEM", .T., .F.)

              dbUseArea(.T., , "SX2010.DTC", "DBF_TABELA", .T., .F.)
              dbUseArea(.T., , "SX3010.DTC", "DBF_ORIGEM", .T., .F.)

           Endif

      Case Substr(cOrigem,01,02) == "02"
           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2020.DBF", "DBF_ORIGEM", .T., .F.)
              dbUseArea(.T., , "SX2020.DTC", "DBF_ORIGEM", .T., .F.)
           Else
//            dbUseArea(.T., "DBFCDX", "SX2020.DBF", "DBF_TABELA", .T., .F.)
//            dbUseArea(.T., "DBFCDX", "SX3020.DBF", "DBF_ORIGEM", .T., .F.)

              dbUseArea(.T., , "SX2020.DTC", "DBF_TABELA", .T., .F.)
              dbUseArea(.T., , "SX3020.DTC", "DBF_ORIGEM", .T., .F.)

           Endif

      Case Substr(cOrigem,01,02) == "03"
           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2030.DBF", "DBF_ORIGEM", .T., .F.)
              dbUseArea(.T., , "SX2030.DTC", "DBF_ORIGEM", .T., .F.)
           Else
//              dbUseArea(.T., "DBFCDX", "SX2030.DBF", "DBF_TABELA", .T., .F.)
//              dbUseArea(.T., "DBFCDX", "SX3030.DBF", "DBF_ORIGEM", .T., .F.)

              dbUseArea(.T., , "SX2030.DTC", "DBF_TABELA", .T., .F.)
              dbUseArea(.T., , "SX3030.DTC", "DBF_ORIGEM", .T., .F.)

           Endif
   EndCase

   // Inicializa variáveis de trabalho
   aTransito := {}
   aBrowse   := {}
                            
   // SX2 - Carrega o array aBrowse
   If Substr(cArquivos,01,02) == "01"

      dbSelectArea("DBF_ORIGEM")
      dbSetOrder(1)

      While !DBF_ORIGEM->(EOF()) 

         If Substr(cArquivos,01,02) == "01"

            AAdd(aTransito, {"2"                    ,; // 01 - Legenda
                             DBF_ORIGEM->X2_CHAVE   ,; // 02 - Nome da Tabela
                             DBF_ORIGEM->X2_NOME    ,; // 03 - Descrição da Tabela
                             ""                     ,; // 04 - Observações
                             ""                     ,; // 05 - Indica se registro está agendado para atualização
                             DBF_ORIGEM->X2_PATH    ,; // 06 -
                             DBF_ORIGEM->X2_ARQUIVO ,; // 07 -
                             DBF_ORIGEM->X2_NOMESPA ,; // 08 -
                             DBF_ORIGEM->X2_NOMEENG ,; // 09 -
                             DBF_ORIGEM->X2_ROTINA  ,; // 10 -
                             DBF_ORIGEM->X2_MODO    ,; // 11 -
                             DBF_ORIGEM->X2_MODOUN  ,; // 12 -
                             DBF_ORIGEM->X2_MODOEMP ,; // 13 -
                             DBF_ORIGEM->X2_DELET   ,; // 14 -
                             DBF_ORIGEM->X2_TTS     ,; // 15 -
                             DBF_ORIGEM->X2_UNICO   ,; // 16 -
                             DBF_ORIGEM->X2_PYME    ,; // 17 -
                             DBF_ORIGEM->X2_MODULO  ,; // 18 -
                             DBF_ORIGEM->X2_DISPLAY})  // 19 -
                             
         Endif

         DBF_ORIGEM->(dbSkip())
   
      EndDo

      dbCloseArea()

   Else
   
      dbSelectArea("DBF_ORIGEM")
      dbSetOrder(1)

      While !DBF_ORIGEM->(EOF()) 

         // Pesquisa o nome da tabela
         dbSelectArea("DBF_TABELA")
         dbSetOrder(1)
         If DbSeek(DBF_ORIGEM->X3_ARQUIVO)
            _Nome_da_Tabela := DBF_TABELA->X2_NOME
         Else
            _Nome_da_Tabela := "Não Localizada"
         Endif
            
         dbSelectArea("DBF_ORIGEM")            

         AAdd(aTransito, {"2"                   ,; // 01 - Legenda
                          DBF_ORIGEM->X3_ARQUIVO,; // 02 - Nome da Tabela
                          _Nome_da_Tabela       ,; // 03 - Descrição da Tabela
                          DBF_ORIGEM->X3_CAMPO  ,; // 04 - Nome do Campo
                          DBF_ORIGEM->X3_TITULO ,; // 05 - Descrição do Campo
                          DBF_ORIGEM->X3_TIPO   ,; // 06 - Tipo do Campo
                          DBF_ORIGEM->X3_TAMANHO,; // 07 - Tamanho do Campo
                          DBF_ORIGEM->X3_DECIMAL,; // 08 - Decimal do Campo
                          ""                    ,; // 09 - Observações
                          ""                    ,; // 10 - Indica se registro está agendado para atualização
                          DBF_ORIGEM->X3_ORDEM  ,; // 11 -
                          DBF_ORIGEM->X3_TITSPA ,; // 12 -
                          DBF_ORIGEM->X3_TITENG ,; // 13 -
                          DBF_ORIGEM->X3_DESCRIC,; // 14 -
                          DBF_ORIGEM->X3_DESCSPA,; // 15 -
                          DBF_ORIGEM->X3_DESCENG,; // 16 -
                          DBF_ORIGEM->X3_PICTURE,; // 17 -
                          DBF_ORIGEM->X3_VALID  ,; // 18 -
                          DBF_ORIGEM->X3_USADO  ,; // 19 -
                          DBF_ORIGEM->X3_RELACAO,; // 20 -
                          DBF_ORIGEM->X3_F3     ,; // 21 -
                          DBF_ORIGEM->X3_NIVEL  ,; // 22 -
                          DBF_ORIGEM->X3_RESERV ,; // 23 -
                          DBF_ORIGEM->X3_CHECK  ,; // 24 -
                          DBF_ORIGEM->X3_TRIGGER,; // 25 -
                          DBF_ORIGEM->X3_PROPRI ,; // 26 -
                          DBF_ORIGEM->X3_BROWSE ,; // 27 -
                          DBF_ORIGEM->X3_VISUAL ,; // 28 -
                          DBF_ORIGEM->X3_CONTEXT,; // 29 -
                          DBF_ORIGEM->X3_OBRIGAT,; // 30 -
                          DBF_ORIGEM->X3_VLDUSER,; // 31 -
                          DBF_ORIGEM->X3_CBOX   ,; // 32 -
                          DBF_ORIGEM->X3_CBOXSPA,; // 33 -
                          DBF_ORIGEM->X3_CBOXENG,; // 34 -
                          DBF_ORIGEM->X3_PICTVAR,; // 35 -
                          DBF_ORIGEM->X3_WHEN   ,; // 36 -
                          DBF_ORIGEM->X3_INIBRW ,; // 37 -
                          DBF_ORIGEM->X3_GRPSXG ,; // 38 -
                          DBF_ORIGEM->X3_FOLDER ,; // 39 -
                          DBF_ORIGEM->X3_PYME   ,; // 40 -
                          DBF_ORIGEM->X3_CONDSQL,; // 41 -
                          DBF_ORIGEM->X3_CHKSQL ,; // 42 -
                          DBF_ORIGEM->X3_IDXSRV ,; // 43 -
                          DBF_ORIGEM->X3_ORTOGRA,; // 44 -
                          DBF_ORIGEM->X3_IDXFLD ,; // 45 -
                          DBF_ORIGEM->X3_TELA   ,; // 46 -
                          ""                    }) // 47 - Help

         DBF_ORIGEM->(dbSkip())
   
      EndDo

      dbCloseArea()
      
   Endif

   // Abre o arquivo do Destino
   Do Case
      Case Substr(cDestino,01,02) == "01"
           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2010.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX2010.DTC", "DBF_DESTINO", .T., .F.)
           Else
//            dbUseArea(.T., "DBFCDX", "SX3010.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX3010.DTC", "DBF_DESTINO", .T., .F.)
           Endif
      Case Substr(cDestino,01,02) == "02"
           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2020.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX2020.DTC", "DBF_DESTINO", .T., .F.)
           Else
//            dbUseArea(.T., "DBFCDX", "SX3020.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX3020.DTC", "DBF_DESTINO", .T., .F.)
           Endif
      Case Substr(cDestino,01,02) == "03"
           If Substr(cArquivos,01,02) == "01"
//            dbUseArea(.T., "DBFCDX", "SX2030.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX2030.DTC", "DBF_DESTINO", .T., .F.)
           Else
//            dbUseArea(.T., "DBFCDX", "SX3030.DBF", "DBF_DESTINO", .T., .F.)
              dbUseArea(.T., , "SX3030.DTC", "DBF_DESTINO", .T., .F.)
           Endif
   EndCase
                            
   // SX2
   If Substr(cArquivos,01,02) == "01"

      For nContar = 1 to Len(aTransito)

          dbSelectArea("DBF_DESTINO")
          dbSetOrder(1)
          If DbSeek(aTransito[nContar,02])
             aTransito[nContar,01] := "2"
             aTransito[nContar,04] := "Tabela OK"
          Else
             aTransito[nContar,01] := "8"
             aTransito[nContar,04] := "Tabela inexistente na Empresa Destino"
          Endif
          
      Next nContar

      dbCloseArea()

   Else

      For nContar = 1 to Len(aTransito)

          cObservacao := ""
          lTem_Erro   := .F.

          dbSelectArea("DBF_DESTINO")
          dbSetOrder(2)
          If DbSeek(aTransito[nContar,04])

             // ######################################
             // Verifica se o tipo do campo é igual ##
             // ######################################
             If aTransito[nContar,06] <> DBF_DESTINO->X3_TIPO
                cObservacao := cObservacao + "Tipo Inconsistente [ " + aTransito[nContar,06] + " - " + DBF_DESTINO->X3_TIPO + " ] - "
                lTem_Erro   := .T.
             Endif
                                                      
             // #########################################   
             // Verifica se o tamanho do campo é igual ##
             // #########################################
             If aTransito[nContar,07] <> DBF_DESTINO->X3_TAMANHO
                cObservacao := cObservacao + "Tamanho Inconsistente [ " + Alltrim(str(aTransito[nContar,07])) + " - " + Alltrim(Str(DBF_DESTINO->X3_TAMANHO)) + " ] - "
                lTem_Erro   := .T.
             Endif
                                                         
             // #########################################
             // Verifica se o decimal do campo é igual ##
             // #########################################
             If aTransito[nContar,08] <> DBF_DESTINO->X3_DECIMAL
                cObservacao := cObservacao + "Decimal Inconsistente [ " + Alltrim(str(aTransito[nContar,08])) + " - " + Alltrim(str(DBF_DESTINO->X3_DECIMAL)) + " ] - "
                lTem_Erro   := .T.
             Endif                               
                                             
             // #############################
             // Verifica o campo validação ##
             // #############################
             If aTransito[nContar,18] <> DBF_DESTINO->X3_VALID
                cObservacao := cObservacao + "Validação Inconsistente [ " + Alltrim(aTransito[nContar,18]) + " - " + Alltrim(DBF_DESTINO->X3_VALID) + " ] - "
                lTem_Erro   := .T.
             Endif                               

             aTransito[nContar,09] := cObservacao
                                                         
              // ################################
             // Se campo existe, legenda Verde ##
             // #################################
             If lTem_Erro == .T.      
                aTransito[nContar,01] := "8"
             Else
                aTransito[nContar,01] := "2"
             Endif
             
          Else
             
             // Se campo existe, legenda Verde
             aTransito[nContar,01] := "8"
             aTransito[nContar,09] := "Campo inexistente: Tipo: " + aTransito[nContar,06] + " Tamanho: " + Alltrim(Str(aTransito[nContar,07])) + " Decimal: " + Alltrim(str(aTransito[nContar,08]))
             
          Endif

      Next nContar

      dbSelectArea("DBF_DESTINO")
      dbCloseArea()
      dbSelectArea("DBF_TABELA")
      dbCloseArea()
      
   Endif

   // Filtra conforme parametrização informada
   aBrowse := {}
   
   nTotRegistros := Len(aTransito)
   nTotRegOK     := 0
   nTotRegNOK    := 0

   For nContar = 1 to Len(aTransito)

       Do Case
          Case Substr(cVisual,01,02) == "01"

               If aTransito[nContar,01] == "2"

                  // Carrega dados da SX2
                  If Substr(cArquivos,01,02) == "01"
                     aAdd( aBrowse, { aTransito[nContar,01],;
                                      aTransito[nContar,02],;
                                      aTransito[nContar,03],;
                                      aTransito[nContar,04],;
                                      aTransito[nContar,05],;
                                      aTransito[nContar,06],;
                                      aTransito[nContar,07],;
                                      aTransito[nContar,08],;
                                      aTransito[nContar,09],;
                                      aTransito[nContar,10],;
                                      aTransito[nContar,11],;
                                      aTransito[nContar,12],;
                                      aTransito[nContar,13],;
                                      aTransito[nContar,14],;
                                      aTransito[nContar,15],;
                                      aTransito[nContar,16],;
                                      aTransito[nContar,17],;
                                      aTransito[nContar,18],;
                                      aTransito[nContar,19]})
                     nTotRegOK := nTotRegOK + 1
            
                  Else
            
                     // Carrega dados da SX3
                     AAdd(aBrowse, {aTransito[nContar,01],;
                                    aTransito[nContar,02],;
                                    aTransito[nContar,03],;
                                    aTransito[nContar,04],;
                                    aTransito[nContar,05],;
                                    aTransito[nContar,06],;
                                    aTransito[nContar,07],;
                                    aTransito[nContar,08],;
                                    aTransito[nContar,09],;
                                    aTransito[nContar,10],;
                                    aTransito[nContar,11],;
                                    aTransito[nContar,12],;
                                    aTransito[nContar,13],;
                                    aTransito[nContar,14],;
                                    aTransito[nContar,15],;
                                    aTransito[nContar,16],;
                                    aTransito[nContar,17],;
                                    aTransito[nContar,18],;
                                    aTransito[nContar,19],;
                                    aTransito[nContar,20],;
                                    aTransito[nContar,21],;
                                    aTransito[nContar,22],;
                                    aTransito[nContar,23],;
                                    aTransito[nContar,24],;
                                    aTransito[nContar,25],;
                                    aTransito[nContar,26],;
                                    aTransito[nContar,27],;
                                    aTransito[nContar,28],;
                                    aTransito[nContar,29],;
                                    aTransito[nContar,30],;
                                    aTransito[nContar,31],;
                                    aTransito[nContar,32],;
                                    aTransito[nContar,33],;
                                    aTransito[nContar,34],;
                                    aTransito[nContar,35],;
                                    aTransito[nContar,36],;
                                    aTransito[nContar,37],;
                                    aTransito[nContar,38],;
                                    aTransito[nContar,39],;
                                    aTransito[nContar,40],;
                                    aTransito[nContar,41],;
                                    aTransito[nContar,42],;
                                    aTransito[nContar,43],;
                                    aTransito[nContar,44],;
                                    aTransito[nContar,45],;
                                    aTransito[nContar,46],;
                                    aTransito[nContar,47]})

                  Endif
                     
               Endif                      

          Case Substr(cVisual,01,02) == "02"

               If aTransito[nContar,01] == "8"

                  // Carrega dados da SX2
                  If Substr(cArquivos,01,02) == "01"
                     aAdd( aBrowse, { aTransito[nContar,01],;
                                      aTransito[nContar,02],;
                                      aTransito[nContar,03],;
                                      aTransito[nContar,04],;
                                      aTransito[nContar,05],;
                                      aTransito[nContar,06],;
                                      aTransito[nContar,07],;
                                      aTransito[nContar,08],;
                                      aTransito[nContar,09],;
                                      aTransito[nContar,10],;
                                      aTransito[nContar,11],;
                                      aTransito[nContar,12],;
                                      aTransito[nContar,13],;
                                      aTransito[nContar,14],;
                                      aTransito[nContar,15],;
                                      aTransito[nContar,16],;
                                      aTransito[nContar,17],;
                                      aTransito[nContar,18],;
                                      aTransito[nContar,19]})
                     nTotRegOK := nTotRegOK + 1

                  Else

                     // Carrega dados da SX3
                     AAdd(aBrowse, {aTransito[nContar,01],;
                                    aTransito[nContar,02],;
                                    aTransito[nContar,03],;
                                    aTransito[nContar,04],;
                                    aTransito[nContar,05],;
                                    aTransito[nContar,06],;
                                    aTransito[nContar,07],;
                                    aTransito[nContar,08],;
                                    aTransito[nContar,09],;
                                    aTransito[nContar,10],;
                                    aTransito[nContar,11],;
                                    aTransito[nContar,12],;
                                    aTransito[nContar,13],;
                                    aTransito[nContar,14],;
                                    aTransito[nContar,15],;
                                    aTransito[nContar,16],;
                                    aTransito[nContar,17],;
                                    aTransito[nContar,18],;
                                    aTransito[nContar,19],;
                                    aTransito[nContar,20],;
                                    aTransito[nContar,21],;
                                    aTransito[nContar,22],;
                                    aTransito[nContar,23],;
                                    aTransito[nContar,24],;
                                    aTransito[nContar,25],;
                                    aTransito[nContar,26],;
                                    aTransito[nContar,27],;
                                    aTransito[nContar,28],;
                                    aTransito[nContar,29],;
                                    aTransito[nContar,30],;
                                    aTransito[nContar,31],;
                                    aTransito[nContar,32],;
                                    aTransito[nContar,33],;
                                    aTransito[nContar,34],;
                                    aTransito[nContar,35],;
                                    aTransito[nContar,36],;
                                    aTransito[nContar,37],;
                                    aTransito[nContar,38],;
                                    aTransito[nContar,39],;
                                    aTransito[nContar,40],;
                                    aTransito[nContar,41],;
                                    aTransito[nContar,42],;
                                    aTransito[nContar,43],;
                                    aTransito[nContar,44],;
                                    aTransito[nContar,45],;
                                    aTransito[nContar,46],;
                                    aTransito[nContar,47]})

                  Endif

               Endif                      

          Otherwise

               // Carrega dados da SX2
               If Substr(cArquivos,01,02) == "01"
                  aAdd( aBrowse, { aTransito[nContar,01],;
                                   aTransito[nContar,02],;
                                   aTransito[nContar,03],;
                                   aTransito[nContar,04],;
                                   aTransito[nContar,05],;
                                   aTransito[nContar,06],;
                                   aTransito[nContar,07],;
                                   aTransito[nContar,08],;
                                   aTransito[nContar,09],;
                                   aTransito[nContar,10],;
                                   aTransito[nContar,11],;
                                   aTransito[nContar,12],;
                                   aTransito[nContar,13],;
                                   aTransito[nContar,14],;
                                   aTransito[nContar,15],;
                                   aTransito[nContar,16],;
                                   aTransito[nContar,17],;
                                   aTransito[nContar,18],;
                                   aTransito[nContar,19]})
                  nTotRegOK := nTotRegOK + 1

               Else

                  // Carrega dados da SX3
                     AAdd(aBrowse, {aTransito[nContar,01],;
                                    aTransito[nContar,02],;
                                    aTransito[nContar,03],;
                                    aTransito[nContar,04],;
                                    aTransito[nContar,05],;
                                    aTransito[nContar,06],;
                                    aTransito[nContar,07],;
                                    aTransito[nContar,08],;
                                    aTransito[nContar,09],;
                                    aTransito[nContar,10],;
                                    aTransito[nContar,11],;
                                    aTransito[nContar,12],;
                                    aTransito[nContar,13],;
                                    aTransito[nContar,14],;
                                    aTransito[nContar,15],;
                                    aTransito[nContar,16],;
                                    aTransito[nContar,17],;
                                    aTransito[nContar,18],;
                                    aTransito[nContar,19],;
                                    aTransito[nContar,20],;
                                    aTransito[nContar,21],;
                                    aTransito[nContar,22],;
                                    aTransito[nContar,23],;
                                    aTransito[nContar,24],;
                                    aTransito[nContar,25],;
                                    aTransito[nContar,26],;
                                    aTransito[nContar,27],;
                                    aTransito[nContar,28],;
                                    aTransito[nContar,29],;
                                    aTransito[nContar,30],;
                                    aTransito[nContar,31],;
                                    aTransito[nContar,32],;
                                    aTransito[nContar,33],;
                                    aTransito[nContar,34],;
                                    aTransito[nContar,35],;
                                    aTransito[nContar,36],;
                                    aTransito[nContar,37],;
                                    aTransito[nContar,38],;
                                    aTransito[nContar,39],;
                                    aTransito[nContar,40],;
                                    aTransito[nContar,41],;
                                    aTransito[nContar,42],;
                                    aTransito[nContar,43],;
                                    aTransito[nContar,44],;
                                    aTransito[nContar,45],;
                                    aTransito[nContar,46],;
                                    aTransito[nContar,47]})

               Endif

               If aTransito[nContar,01] == "2"
                  nTotRegOK := nTotRegOK + 1
               Endif

               If aTransito[nContar,01] == "8"                  
                  nTotRegNOK := nTotRegNOK + 1
               Endif

       EndCase
                                   
   Next nContar

   // Ver se já existe agendamento para os registros
   Do Case
      Case Substr(cArquivos,01,02) == "01"
           Do Case
              Case Substr(cDestino,01,02) == "01"
                   xArquivo := "\cfglog\sx2x3101"
              Case Substr(cDestino,01,02) == "02"
                   xArquivo := "\cfglog\sx2x3102"
              Case Substr(cDestino,01,02) == "03"
                   xArquivo := "\cfglog\sx2x3103"
           EndCase
      Case Substr(cArquivos,01,02) == "02"
           Do Case
              Case Substr(cDestino,01,02) == "01"
                   xArquivo := "\cfglog\sx3x3101"
              Case Substr(cDestino,01,02) == "02"
                   xArquivo := "\cfglog\sx3x3102"
              Case Substr(cDestino,01,02) == "03"
                   xArquivo := "\cfglog\sx3x3103"
           EndCase
   EndCase

   // Verifica se existe o arquivo selecionado (CFGLOG.DTC) para leitura
   If File(xArquivo + ".dtc")

      If Select("T_ARQUIVOS") > 0
         T_ARQUIVOS->( dbCloseArea() )
      EndIf

      dbUseArea( .T.,"CTREECDX", xArquivo, "T_ARQUIVOS", .T., .F. ) 
   
      If Substr(cArquivos,01,02) == "01"

         nTotRegAgen := 0

         For nContar = 1 to Len(aBrowse)
         
             aBrowse[nContar,05] := "A REALIZAR"

             T_ARQUIVOS->( DbGoTop() )
             
             WHILE !T_ARQUIVOS->( EOF() )
                If Alltrim(T_ARQUIVOS->X2_CHAVE) == Alltrim(aBrowse[nContar,02])
                   aBrowse[nContar,01] := "4"
                   aBrowse[nContar,05] := "Agendado"
                   nTotRegAgen := nTotRegAgen + 1
                   Exit
                Endif
                T_ARQUIVOS->( DbSkip() )
             ENDDO
             
         Next nContar
         
      ELSE
      
         nTotRegAgen := 0

         For nContar = 1 to Len(aBrowse)
         
             aBrowse[nContar,10] := "A REALIZAR"

             T_ARQUIVOS->( DbGoTop() )
             
             WHILE !T_ARQUIVOS->( EOF() )
                If Alltrim(T_ARQUIVOS->X3_ARQUIVO) == Alltrim(aBrowse[nContar,02]) .And. ;
                   Alltrim(T_ARQUIVOS->X3_CAMPO)   == Alltrim(aBrowse[nContar,04])
                   aBrowse[nContar,01] := "4"
                   aBrowse[nContar,10] := "Agendado"
                   nTotRegAgen := nTotRegAgen + 1
                   Exit
                Endif
                T_ARQUIVOS->( DbSkip() )
             ENDDO
             
         Next nContar
      
      Endif
      
   Endif

   If Len(aBrowse) == 0
      If Substr(cDestino,01,02) == "01"
         aAdd( aBrowse, { "1", "", "", "", "" } )      
      Else         
         aAdd( aBrowse, { "1", "", "", "", "", "", "", "", "", "" } )      
      Endif   
   Endif      

Return(.T.)

// Função que gera em txt o resultado pesquisado
Static Function GeraTXTResult()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet2

   Private oDlgTXT

   DEFINE MSDIALOG oDlgTXT TITLE "Verificador Discionário de Dados" FROM C(178),C(181) TO C(350),C(605) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgTXT

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(203),C(001) PIXEL OF oDlgTXT
   @ C(061),C(005) GET oMemo2 Var cMemo2 MEMO Size C(203),C(001) PIXEL OF oDlgTXT
   
   @ C(039),C(005) Say "Informe caminho e arquivo para gerar o TXT do resultado" Size C(137),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT

   @ C(048),C(005) MsGet oGet2 Var cCaminho Size C(203),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT

   @ C(068),C(068) Button "Gerar TXT" Size C(037),C(012) PIXEL OF oDlgTXT ACTION( GravaArqTXT() )
   @ C(068),C(109) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgTXT ACTION( oDlgTXT:End() )

   ACTIVATE MSDIALOG oDlgTXT CENTERED 

Return(.T.)

// Função que gera em txt o resultado pesquisado
Static Function GravaArqTXT()

   Local nContar := 0
   Local cString := ""
   
   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho + Arquivo não informado para geração do arquivo TXT.")
      Return(.T.)
   Endif
      
   cString := ""

   // Cria a cabeçalho do arquivo
   If Substr(cArquivos,01,02) == "01"
      cString := cString + "DICIONÁRIO......: SX2" + chr(13) + chr(10)
   Else
      cString := cString + "DICIONÁRIO......: SX3" + chr(13) + chr(10)
   Endif

   Do Case
      Case Substr(cDestino,01,02) == "01"
           cString := cString + "DADOS DA EMPRESA: AUTOMATECH"   + chr(13) + chr(10) + chr(13) + chr(10)
      Case Substr(cDestino,01,02) == "02"
           cString := cString + "DADOS DA EMPRESA: TI AUTOMAÇÃO" + chr(13) + chr(10) + chr(13) + chr(10)
      Case Substr(cDestino,01,02) == "03"
           cString := cString + "DADOS DA EMPRESA: ATECH"        + chr(13) + chr(10) + chr(13) + chr(10)
   EndCase

   // Inclui os dados
   For nContar = 1 to Len(aBrowse)      
       
       If Substr(cArquivos,01,02) == "01"
          cString := cString + aBrowse[nContar,02] + "  " + ;
                               aBrowse[nContar,03] + "  " + ;
                               aBrowse[nContar,04] + "  " + ;
                               aBrowse[nContar,05] + "  " + ;
                               aBrowse[nContar,06] + "  " + ;
                               aBrowse[nContar,07] + "  " + ;
                               aBrowse[nContar,08] + "  " + ;
                               aBrowse[nContar,09] + chr(13) + chr(10)
       Else
          cString := cString + aBrowse[nContar,02] + "  " + ;
                               aBrowse[nContar,03] + "  " + ;
                               aBrowse[nContar,04] + "  " + ;
                               aBrowse[nContar,05] + "  " + ;
                               aBrowse[nContar,06] + "  " + ;
                               Alltrim(Str(aBrowse[nContar,07])) + "  " + ;
                               Alltrim(Str(aBrowse[nContar,08])) + "  " + ;
                               aBrowse[nContar,09] + chr(13) + chr(10)
       Endif
   
   Next nContar   
   
   // Salva o arquivo de log de Baixas
   cCaminho := Alltrim(cCaminho)

   nHdl := fCreate(cCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)
   
   oDlgTXT:End() 

Return(.T.)

// Função que seleciona o agendamento do arquivo CFGLOG.DTC
Static Function AgendaCFGLOG()

   Local lChumba  := .F.
   Local nContar  := 0

   Local cMemo1	  := ""
   Local cMemo2	  := ""
   Local oMemo1
   Local oMemo2

   Local oOk      := LoadBitmap( GetResources(), "LBOK" )
   Local oNo      := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

   Private oDlgAg

   DEFINE MSDIALOG oDlgAg TITLE "Verificador Discionário de Dados" FROM C(178),C(181) TO C(639),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgAg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgAg
   @ C(072),C(005) GET oMemo2 Var cMemo2 MEMO Size C(383),C(139) PIXEL OF oDlgAg

   @ C(038),C(067) Say "Disc. Empresa a Verificar"         Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgAg
   @ C(039),C(005) Say "Disc. Empresa Base"                Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgAg
   @ C(039),C(132) Say "Verificar o Arquivo do Dicionário" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgAg
   @ C(039),C(282) Say "Visualizar"                        Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgAg
   @ C(063),C(005) Say "Resultado da Verificação"          Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgAg
   
   @ C(049),C(005) ComboBox cOrigem   Items aOrigem   Size C(056),C(010) PIXEL OF oDlgAg When lChumba
   @ C(049),C(066) ComboBox cDestino  Items aDestino  Size C(056),C(010) PIXEL OF oDlgAg When lChumba
   @ C(049),C(132) ComboBox cArquivos Items aArquivos Size C(143),C(010) PIXEL OF oDlgAg When lChumba
   @ C(049),C(282) ComboBox cVisual   Items aVisual   Size C(106),C(010) PIXEL OF oDlgAg When lChumba

   @ C(214),C(005) Button "Marcar Todos"          Size C(047),C(012) PIXEL OF oDlgAg ACTION( MMTodos(1) )
   @ C(214),C(053) Button "Desmarcar Todos"       Size C(047),C(012) PIXEL OF oDlgAg ACTION( MMTodos(2) )
   @ C(214),C(186) Button "Confirmar Agendamento" Size C(075),C(012) PIXEL OF oDlgAg ACTION( GeraAgenda() )
   @ C(214),C(351) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlgAg ACTION( oDlgAg:End() )

   aLista := {}
 
   // Carrega o array aLista para disponibilizar ao usuário selecionar os campo sdesejados
   If Substr(cArquivos,01,02) == "01"

      For nContar = 1 to Len(aBrowse)

          If aBrowse[nContar,01] <> "8"
             Loop
          Endif

          If UPPER(Substr(aBrowse[nContar,09],01,18)) <> "TABELA INEXISTENTE"
             Loop
          Endif                                                        

          aAdd( aLista, { .F.               ,;
                          aBrowse[nContar,02],;
                          aBrowse[nContar,03],;
                          aBrowse[nContar,04],;
                          aBrowse[nContar,05],;
                          aBrowse[nContar,06],;
                          aBrowse[nContar,07],;
                          aBrowse[nContar,08],;
                          aBrowse[nContar,09],;
                          aBrowse[nContar,10],;
                          aBrowse[nContar,11],;
                          aBrowse[nContar,12],;
                          aBrowse[nContar,13],;
                          aBrowse[nContar,14],;
                          aBrowse[nContar,15],;
                          aBrowse[nContar,16],;
                          aBrowse[nContar,17],;
                          aBrowse[nContar,18],;
                          aBrowse[nContar,19]})
      Next nContar
 
   Else
   
      For nContar = 1 to Len(aBrowse)

          If aBrowse[nContar,01] <> "8"
             Loop
          Endif

          If UPPER(Substr(aBrowse[nContar,09],01,17)) <> "CAMPO INEXISTENTE"
             Loop
          Endif                                                        

          aAdd( aLista, { .F.               ,;
                          aBrowse[nContar,02],;
                          aBrowse[nContar,03],;
                          aBrowse[nContar,04],;
                          aBrowse[nContar,05],;
                          aBrowse[nContar,06],;
                          aBrowse[nContar,07],;
                          aBrowse[nContar,08],;
                          aBrowse[nContar,09],;
                          aBrowse[nContar,10],;
                          aBrowse[nContar,11],;
                          aBrowse[nContar,12],;
                          aBrowse[nContar,13],;
                          aBrowse[nContar,14],;
                          aBrowse[nContar,15],;
                          aBrowse[nContar,16],;
                          aBrowse[nContar,17],;
                          aBrowse[nContar,18],;
                          aBrowse[nContar,19],;
                          aBrowse[nContar,20],;
                          aBrowse[nContar,21],;
                          aBrowse[nContar,22],;
                          aBrowse[nContar,23],;
                          aBrowse[nContar,24],;
                          aBrowse[nContar,25],;
                          aBrowse[nContar,26],;
                          aBrowse[nContar,27],;
                          aBrowse[nContar,28],;
                          aBrowse[nContar,29],;
                          aBrowse[nContar,30],;
                          aBrowse[nContar,31],;
                          aBrowse[nContar,32],;
                          aBrowse[nContar,33],;
                          aBrowse[nContar,34],;
                          aBrowse[nContar,35],;
                          aBrowse[nContar,36],;
                          aBrowse[nContar,37],;
                          aBrowse[nContar,38],;
                          aBrowse[nContar,39],;
                          aBrowse[nContar,40],;
                          aBrowse[nContar,41],;
                          aBrowse[nContar,42],;
                          aBrowse[nContar,43],;
                          aBrowse[nContar,44],;
                          aBrowse[nContar,45],;
                          aBrowse[nContar,46],;
                          aBrowse[nContar,47]})
      Next nContar
      
   Endif   

   // Display dos vaores do array
   If Substr(cArquivos,01,02) == "01"
      @ 092,005 LISTBOX oLista FIELDS HEADER "M"               ,;
                                             "Descrição Tabela",;
                                             "Observações"     ,;
                                             "Status" PIXEL SIZE 490,177 OF oDlgAg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
      oLista:SetArray( aLista )

      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
              					   aLista[oLista:nAt,02]         ,;
             					   aLista[oLista:nAt,03]         ,;
            					   aLista[oLista:nAt,04]         }}
   Else
      @ 092,005 LISTBOX oLista FIELDS HEADER "M"                     ,;
                                             "Tabela"                ,;
                                             "Descrição das Tabelas" ,;
                                             "Campo"                 ,;
                                             "Descrição dos Campos"  ,;
                                             "Tipo"                  ,;
                                             "Tamanho"               ,;
                                             "Decimal"               ,;
                                             "Observações"     ,;
                                             "Status" PIXEL SIZE 490,177 OF oDlgAg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

      oLista:SetArray( aLista )

      oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
              					   aLista[oLista:nAt,02]         ,;
             					   aLista[oLista:nAt,03]         ,;
            					   aLista[oLista:nAt,04]         ,;
            					   aLista[oLista:nAt,05]         ,;
            					   aLista[oLista:nAt,06]         ,;
            					   aLista[oLista:nAt,07]         ,;
            					   aLista[oLista:nAt,08]         ,;
            					   aLista[oLista:nAt,09]         ,;
            					   aLista[oLista:nAt,10]         }}
   Endif

   ACTIVATE MSDIALOG oDlgAg CENTERED 

Return(.T.)

// Função que marca e desmarca os registros
Static Function MMTodos(__Botao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       
       If __Botao == 1
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.          
       Endif
   
   Next nContar
   
Return(.T.)

// Função que gera o agendamento conforme seleção do arquivo
Static Function GeraAgenda()

   Local nContar    := 0
   Local cEstrutura := ""

   // Verifica se houve pelo menos um registro marcado para atualização
   lMarcados := .F.
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi marcado para atualização.")
      Return(.T.)
   Endif

   // Envia para a função que cria o arquivo Ctree conforme informação
   Cria_Ctree()

   // Abre o arquivo para gravação dos dados
   If Substr(cArquivos,01,02) == "01"
      Do Case
         Case Substr(cDestino,01,02) == "01"
              cEstrutura := "\cfglog\sx2x3101"
         Case Substr(cDestino,01,02) == "02"
              cEstrutura := "\cfglog\sx2x3102"
         Case Substr(cDestino,01,02) == "03"
              cEstrutura := "\cfglog\sx2x3103"
      EndCase        
   Else
      Do Case
         Case Substr(cDestino,01,02) == "01"
              cEstrutura := "\cfglog\sx3x3101"
         Case Substr(cDestino,01,02) == "02"
              cEstrutura := "\cfglog\sx3x3102"
         Case Substr(cDestino,01,02) == "03"
              cEstrutura := "\cfglog\sx3x3103"
      EndCase        
   Endif
      
   // Atualiza os dados no arquivo selecionado
   If Substr(cArquivos,01,02) == "01"
   
      If Select("T_CAMPOS") > 0
         T_CAMPOS->( dbCloseArea() )
      EndIf

      dbUseArea( .T.,"CTREECDX", cEstrutura, "T_CAMPOS", .T., .F. ) 

      For nContar = 1 to Len(aLista)
         
          If aLista[nContar,01] == .F.
             Loop
          Endif
             
          dbSelectArea("T_CAMPOS")
          RecLock("T_CAMPOS",.T.)
             X2_CHAVE   := aLista[nContar,02]
             X2_PATH    := aLista[nContar,06]
             X2_ARQUIVO := aLista[nContar,07]
             X2_NOME    := aLista[nContar,03]
             X2_NOMESPA := aLista[nContar,08]
             X2_NOMEENG := aLista[nContar,09]
             X2_ROTINA  := aLista[nContar,10]
             X2_MODO    := aLista[nContar,11]
             X2_MODOUN  := aLista[nContar,12]
             X2_MODOEMP := aLista[nContar,13]
             X2_DELET   := aLista[nContar,14]
             X2_TTS     := aLista[nContar,15]
             X2_UNICO   := aLista[nContar,16]
             X2_PYME    := aLista[nContar,17]
             X2_MODULO  := Int(aLista[nContar,18])
             X2_DISPLAY := aLista[nContar,19]
          MsUnLock()
                
      Next nContar

   Else

      If Select("T_CAMPOS") > 0
         T_CAMPOS->( dbCloseArea() )
      EndIf

      dbUseArea( .T.,"CTREECDX", cEstrutura, "T_CAMPOS", .T., .F. ) 

      For nContar = 1 to Len(aLista)
         
          If aLista[nContar,01] == .F.
             Loop
          Endif
             
          dbSelectArea("T_CAMPOS")
          RecLock("T_CAMPOS",.T.)
             X3_ARQUIVO := aLista[nContar,02]
             X3_ORDEM   := aLista[nContar,11]
             X3_CAMPO   := aLista[nContar,04]
             X3_TIPO    := aLista[nContar,06]
             X3_TAMANHO := aLista[nContar,07]
             X3_DECIMAL := aLista[nContar,08]
             X3_TITULO  := aLista[nContar,05]
             X3_TITSPA  := aLista[nContar,12]
             X3_TITENG  := aLista[nContar,13]
             X3_DESCRIC := aLista[nContar,14]
             X3_DESCSPA := aLista[nContar,15]
             X3_DESCENG := aLista[nContar,16]
             X3_PICTURE := aLista[nContar,17]
             X3_VALID   := aLista[nContar,18]
             X3_USADO   := aLista[nContar,19]
             X3_RELACAO := aLista[nContar,20]
             X3_F3      := aLista[nContar,21]
             X3_NIVEL   := aLista[nContar,22]
             X3_RESERV  := aLista[nContar,23]
             X3_CHECK   := aLista[nContar,24]
             X3_TRIGGER := aLista[nContar,25]
             X3_PROPRI  := aLista[nContar,26]
             X3_BROWSE  := aLista[nContar,27]
             X3_VISUAL  := aLista[nContar,28]
             X3_CONTEXT := aLista[nContar,29]
             X3_OBRIGAT := aLista[nContar,30]
             X3_VLDUSER := aLista[nContar,31]
             X3_CBOX    := aLista[nContar,32]
             X3_CBOXSPA := aLista[nContar,33]
             X3_CBOXENG := aLista[nContar,34]
             X3_PICTVAR := aLista[nContar,35]
             X3_WHEN    := aLista[nContar,36]
             X3_INIBRW  := aLista[nContar,37]
             X3_GRPSXG  := aLista[nContar,38]
             X3_FOLDER  := aLista[nContar,39]
             X3_PYME    := aLista[nContar,40]
             X3_CONDSQL := aLista[nContar,41]
             X3_CHKSQL  := aLista[nContar,42]
             X3_IDXSRV  := aLista[nContar,43]
             X3_ORTOGRA := aLista[nContar,44]
             X3_IDXFLD  := aLista[nContar,45]
             X3_TELA    := aLista[nContar,46]
             X3_HELP    := aLista[nContar,47]
          MsUnLock()
                
      Next nContar

   Endif

   MsgAlert("Registros agendados com sucesso." + chr(13) + chr(10) + "Entre no Configurador do Protheus para realizar a atualização do dicionário de dados.")

   oDlg:End()
   oDlgAg:End()
   
Return(.T.)

// Função que cria o arquivo para receber dos dados conforme informações
Static Function Cria_Ctree()

   Local lMarcados := .F.
   Local cArqCria  := ""
   Local aCampos   := {}

   // Prepara o arquivo a ser aberto
   If Substr(cArquivos,01,02) == "01"
      Do Case
         Case Substr(cDestino,01,02) == "01"
              cArqCria := "\cfglog\sx2x3101"
         Case Substr(cDestino,01,02) == "02"
              cArqCria := "\cfglog\sx2x3102"
         Case Substr(cDestino,01,02) == "03"
              cArqCria := "\cfglog\sx2x3103"
      EndCase        
   Else
      Do Case
         Case Substr(cDestino,01,02) == "01"
              cArqCria := "\cfglog\sx3x3101"
         Case Substr(cDestino,01,02) == "02"
              cArqCria := "\cfglog\sx3x3102"
         Case Substr(cDestino,01,02) == "03"
              cArqCria := "\cfglog\sx3x3103"
      EndCase        
   Endif

   // Verifica se existe o arquivo selecionado (CFGLOG.DTC) para leitura
   If File(cArqCria + ".dtc")
      Return(.T.)
   Endif   
   
   // Limpa o array aCampos para receber a estrutura do arquivo a ser criado   
   aCampos := {}

   If Substr(cArquivos,01,02) == "01"

      Aadd(aCampos, {"X2_CHAVE"  , "C",  30, 0})
      Aadd(aCampos, {"X2_PATH"   , "C",  40, 0})
      Aadd(aCampos, {"X2_ARQUIVO", "C",   8, 0})
      Aadd(aCampos, {"X2_NOME"   , "C",  30, 0})
      Aadd(aCampos, {"X2_NOMESPA", "C",  30, 0})
      Aadd(aCampos, {"X2_NOMEENG", "C",  30, 0})
      Aadd(aCampos, {"X2_ROTINA" , "C",  40, 0})
      Aadd(aCampos, {"X2_MODO"   , "C",   1, 0})
      Aadd(aCampos, {"X2_MODOUN" , "C",   1, 0})
      Aadd(aCampos, {"X2_MODOEMP", "C",   1, 0})
      Aadd(aCampos, {"X2_DELET"  , "N",   1, 0})
      Aadd(aCampos, {"X2_TTS"    , "C",   1, 0})
      Aadd(aCampos, {"X2_UNICO"  , "C", 250, 0})
      Aadd(aCampos, {"X2_PYME"   , "C",   1, 0})
      Aadd(aCampos, {"X2_MODULO" , "N",   5, 0})
      Aadd(aCampos, {"X2_DISPLAY", "C", 254, 0})

   Else

      Aadd(aCampos, {"X3_ARQUIVO", "C",   3, 0})
      Aadd(aCampos, {"X3_ORDEM"  , "C",   2, 0})
      Aadd(aCampos, {"X3_CAMPO"  , "C",  10, 0})
      Aadd(aCampos, {"X3_TIPO"   , "C",   1, 0})
      Aadd(aCampos, {"X3_TAMANHO", "N",   3, 0})
      Aadd(aCampos, {"X3_DECIMAL", "N",   2, 0})
      Aadd(aCampos, {"X3_TITULO" , "C",  12, 0})
      Aadd(aCampos, {"X3_TITSPA" , "C",  12, 0})
      Aadd(aCampos, {"X3_TITENG" , "C",  12, 0})
      Aadd(aCampos, {"X3_DESCRIC", "C",  25, 0})
      Aadd(aCampos, {"X3_DESCSPA", "C",  25, 0})
      Aadd(aCampos, {"X3_DESCENG", "C",  25, 0})
      Aadd(aCampos, {"X3_PICTURE", "C",  45, 0})
      Aadd(aCampos, {"X3_VALID"  , "C", 128, 0})
      Aadd(aCampos, {"X3_USADO"  , "C",  15, 0})
      Aadd(aCampos, {"X3_RELACAO", "C", 128, 0})
      Aadd(aCampos, {"X3_F3"     , "C",   6, 0})
      Aadd(aCampos, {"X3_NIVEL"  , "N",   2, 0})
      Aadd(aCampos, {"X3_RESERV" , "C",   2, 0})
      Aadd(aCampos, {"X3_CHECK"  , "C",   1, 0})
      Aadd(aCampos, {"X3_TRIGGER", "C",   1, 0})
      Aadd(aCampos, {"X3_PROPRI" , "C",   1, 0})
      Aadd(aCampos, {"X3_BROWSE" , "C",   1, 0})
      Aadd(aCampos, {"X3_VISUAL" , "C",   1, 0})
      Aadd(aCampos, {"X3_CONTEXT", "C",   1, 0})
      Aadd(aCampos, {"X3_OBRIGAT", "C",   1, 0})
      Aadd(aCampos, {"X3_VLDUSER", "C", 128, 0})
      Aadd(aCampos, {"X3_CBOX"   , "C", 128, 0})
      Aadd(aCampos, {"X3_CBOXSPA", "C", 128, 0})
      Aadd(aCampos, {"X3_CBOXENG", "C", 128, 0})
      Aadd(aCampos, {"X3_PICTVAR", "C",  20, 0})
      Aadd(aCampos, {"X3_WHEN"   , "C",  60, 0})
      Aadd(aCampos, {"X3_INIBRW" , "C",  80, 0})
      Aadd(aCampos, {"X3_GRPSXG" , "C",   3, 0})
      Aadd(aCampos, {"X3_FOLDER" , "C",   1, 0})
      Aadd(aCampos, {"X3_PYME"   , "C",   1, 0})
      Aadd(aCampos, {"X3_CONDSQL", "C", 250, 0})
      Aadd(aCampos, {"X3_CHKSQL" , "C", 250, 0})
      Aadd(aCampos, {"X3_IDXSRV" , "C",   1, 0})
      Aadd(aCampos, {"X3_ORTOGRA", "C",   1, 0})
      Aadd(aCampos, {"X3_IDXFLD" , "C",   1, 0})
      Aadd(aCampos, {"X3_TELA"   , "C",  15, 0})
      Aadd(aCampos, {"X3_HELP"   , "M",  10, 0})

   Endif

   // Cria a tabela conforme estrutura
   DBCreate(cArqCria + ".DTC", aCampos, "CTREECDX")

Return(.T.)