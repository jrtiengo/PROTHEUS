#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

#define DMPAPER_LETTER      1           /* Letter 8 1/2 x 11 in               */
#define DMPAPER_LETTERSMALL 2           /* Letter Small 8 1/2 x 11 in         */
#define DMPAPER_TABLOID     3           /* Tabloid 11 x 17 in                 */
#define DMPAPER_LEDGER      4           /* Ledger 17 x 11 in                  */
#define DMPAPER_LEGAL       5           /* Legal 8 1/2 x 14 in                */
#define DMPAPER_STATEMENT   6           /* Statement 5 1/2 x 8 1/2 in         */
#define DMPAPER_EXECUTIVE   7           /* Executive 7 1/4 x 10 1/2 in        */
#define DMPAPER_A3          8           /* A3 297 x 420 mm                    */
#define DMPAPER_A4          9           /* A4 210 x 297 mm                    */
#define DMPAPER_A4SMALL     10          /* A4 Small 210 x 297 mm              */
#define DMPAPER_A5          11          /* A5 148 x 210 mm                    */
#define DMPAPER_B4          12          /* B4 250 x 354                       */
#define DMPAPER_B5          13          /* B5 182 x 257 mm                    */
#define DMPAPER_FOLIO       14          /* Folio 8 1/2 x 13 in                */
#define DMPAPER_QUARTO      15          /* Quarto 215 x 275 mm                */
#define DMPAPER_10X14       16          /* 10x14 in                           */
#define DMPAPER_11X17       17          /* 11x17 in                           */
#define DMPAPER_NOTE        18          /* Note 8 1/2 x 11 in                 */
#define DMPAPER_ENV_9       19          /* Envelope #9 3 7/8 x 8 7/8          */
#define DMPAPER_ENV_10      20          /* Envelope #10 4 1/8 x 9 1/2         */
#define DMPAPER_ENV_11      21          /* Envelope #11 4 1/2 x 10 3/8        */
#define DMPAPER_ENV_12      22          /* Envelope #12 4 \276 x 11           */
#define DMPAPER_ENV_14      23          /* Envelope #14 5 x 11 1/2            */
#define DMPAPER_CSHEET      24          /* C size sheet                       */
#define DMPAPER_DSHEET      25          /* D size sheet                       */
#define DMPAPER_ESHEET      26          /* E size sheet                       */
#define DMPAPER_ENV_DL      27          /* Envelope DL 110 x 220mm            */
#define DMPAPER_ENV_C5      28          /* Envelope C5 162 x 229 mm           */
#define DMPAPER_ENV_C3      29          /* Envelope C3 324 x 458 mm           */
#define DMPAPER_ENV_C4      30          /* Envelope C4 229 x 324 mm           */
#define DMPAPER_ENV_C6      31          /* Envelope C6 114 x 162 mm           */
#define DMPAPER_ENV_C65     32          /* Envelope C65 114 x 229 mm          */
#define DMPAPER_ENV_B4      33          /* Envelope B4 250 x 353 mm           */
#define DMPAPER_ENV_B5      34          /* Envelope B5 176 x 250 mm           */
#define DMPAPER_ENV_B6      35          /* Envelope B6 176 x 125 mm           */
#define DMPAPER_ENV_ITALY   36          /* Envelope 110 x 230 mm              */
#define DMPAPER_ENV_MONARCH 37          /* Envelope Monarch 3.875 x 7.5 in    */
#define DMPAPER_ENV_PERSONAL 38        /* 6 3/4 Envelope 3 5/8 x 6 1/2 in     */
#define DMPAPER_FANFOLD_US 39          /* US Std Fanfold 14 7/8 x 11 in       */
#define DMPAPER_FANFOLD_STD_GERMAN 40 /* German Std Fanfold 8 1/2 x 12 in     */
#define DMPAPER_FANFOLD_LGL_GERMAN 41 /* German Legal Fanfold 8 1/2 x 13 in   */

//**********************************************************************************
// Referencia: ReportTools.PRW                                                          *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autores ..: Harald Hans Löschenkohl                                             *
//             Lucas Moresco                                                       *
// Data......: 10/06/2016                                                          *
// Objetivo..: Programa ADVPL Tools Report Design                                  *
//**********************************************************************************

User Function ReportTools()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgInicial
  
//   If (ProcName(1) <> "U_ATREPORTDESIGN")
//   	 MsgAlert("Você não tem permissão para executar esta rotina diretamente. Contate o suporte da Advpl Tools.","Atenção")
//   	 Return(.T.)
//   Else

	   // Se for o Administrador, abre o design
	   If Alltrim(Upper(cUserName)) == "ADMINISTRADOR"
	
	      DEFINE MSDIALOG oDlgInicial TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(410),C(397) PIXEL
	
	      @ C(005),C(005) Jpeg FILE "advpltools.png" Size C(102),C(026) PIXEL NOBORDER OF oDlgInicial
	
	      @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(101),C(001) PIXEL OF oDlgInicial
	
	      @ C(035),C(005) Button "REPORT DESIGN" Size C(099),C(025) PIXEL OF oDlgInicial ACTION( ADVPL_DESING() )
	      @ C(061),C(005) Button "COMO USUÁRIO"   Size C(099),C(025) PIXEL OF oDlgInicial ACTION( ADVPL_USUARIO() )
	      @ C(087),C(005) Button "SAIR"          Size C(099),C(025) PIXEL OF oDlgInicial ACTION( oDlgInicial:End() )
	
	      ACTIVATE MSDIALOG oDlgInicial CENTERED 
	
	   Else
	
	      ADVPL_USUARIO()
	
	   Endif
//   EndIf
   
Return(.T.)      

// ####################################################################
// Função que abre a tela Design Report - Somente para Administrador ##
// ####################################################################
Static Function ADVPL_DESING()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private aLista  := {"Item01","Item02"}
   Private cLista

   Private aConsultas := {}

   // Carrega os módulos do sustema Protheus
   aLista := {}

   Aadd(aLista, "00 - Selecione um Módulo" )
   Aadd(aLista, "01 - Ativo" )
   Aadd(aLista, "02 - Compras" )
   Aadd(aLista, "04 - Estoque/Custos" )
   Aadd(aLista, "05 - Faturamento" )
   Aadd(aLista, "06 - Financeiro" )
   Aadd(aLista, "07 - Gestão de Pessoal" )
   Aadd(aLista, "09 - Livros fiscais" )
   Aadd(aLista, "10 - Planejamento Controle Produção" )
   Aadd(aLista, "11 - Veículos" )
   Aadd(aLista, "12 - Controle de Loja" )
   Aadd(aLista, "13 - Call Center" )
   Aadd(aLista, "14 - Oficina" )
   Aadd(aLista, "16 - Ponto Eletrônico" )
   Aadd(aLista, "17 - Easy Import Control" )
   Aadd(aLista, "18 - Terminal de Consulta do Funcionário" )
   Aadd(aLista, "19 - Manutenção de Ativos" )
   Aadd(aLista, "20 - Recruramento e Seleção de Pessoal" )
   Aadd(aLista, "21 - Inspeção de Entradas" )
   Aadd(aLista, "22 - Metrologia" )
   Aadd(aLista, "23 - Front loja" )
   Aadd(aLista, "24 - Controle de Documentos" )
   Aadd(aLista, "26 - Treinamento" )
   Aadd(aLista, "28 - Gestão de Serviços" )
   Aadd(aLista, "29 - Easy Export Control" )
   Aadd(aLista, "30 - Easy Financing" )
   Aadd(aLista, "31 - Easy Accounting" )
   Aadd(aLista, "33 - Plano de Saúde" )
   Aadd(aLista, "34 - Contabilidade Gerencial" )
   Aadd(aLista, "35 - Medicina e Segurança do Trabalho" )
   Aadd(aLista, "36 - Controle de Não-Conformidade" )
   Aadd(aLista, "37 - Controle de Auditoria" )
   Aadd(aLista, "39 - OMS - Gestão de Distribuição" )
   Aadd(aLista, "40 - Cargso e Salários" )
   Aadd(aLista, "41 - Auto Peças" )
   Aadd(aLista, "42 - WMS - Gestão de Armazenagem" )
   Aadd(aLista, "43 - TMS - Gestão de Transporte" )
   Aadd(aLista, "44 - Gestão de Projetos" )
   Aadd(aLista, "45 - Controle de Direitos Autorais" )
   Aadd(aLista, "47 - PPAP" )
   Aadd(aLista, "48 - Réplica" )
   Aadd(aLista, "50 - Easy Dawback Control" )
   Aadd(aLista, "51 - Gestão Hospitalar" )
   Aadd(aLista, "53 - Avaliação e Pesquisa de Desempenho" )
   Aadd(aLista, "55 - Sistema de Fidelização e Análise de Crédito" )
   Aadd(aLista, "56 - Gestão Ambiental" )
   Aadd(aLista, "57 - Planejamento e Controle Orçamentário" )
   Aadd(aLista, "58 - Gerenciamento  de Pesquisa e Resultados" )
   Aadd(aLista, "59 - Gestão de Acervos" )
   Aadd(aLista, "64 - Processos Trabalhistas" )
   Aadd(aLista, "66 - Gestão de Riscos" )
   Aadd(aLista, "67 - Gestão Agrícola" )
   Aadd(aLista, "69 - Gestão de Contratos" )
   Aadd(aLista, "70 - Arquitetura Organizacional" )
   Aadd(aLista, "73 - CRM" )
   Aadd(aLista, "76 - Gestão Jurídica" )
   Aadd(aLista, "77 - Pré Faturamento de Serviços" )
   Aadd(aLista, "78 - Gestão de Frete Embarcador" )
   Aadd(aLista, "79 - Chão de Fábrica" )
   Aadd(aLista, "80 - Acessibilidade Visual" )
   Aadd(aLista, "81 - Monitoramento de Desempenho Logístico" )
   Aadd(aLista, "84 - TOTVS Autuomação Fiscal" )
   Aadd(aLista, "85 - Easy Suscoserv" )
   Aadd(aLista, "89 Promoção da Saúde" )

   // Verifica se existe a pasta advpltools na aplicação. Caso não exista, será criada
   If !ExistDir( "\advpltools" )

      nRet := MakeDir( "\advpltools" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta advpltools. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // Envia para a função que carrega o grid com todas as consultas da pasta advpltools
   CargaConsultas(0)

   Private oDlgConsulta

   DEFINE MSDIALOG oDlgConsulta TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(570),C(910) PIXEL

   @ C(005),C(005) Jpeg FILE "advpltools.png" Size C(107),C(032) PIXEL NOBORDER OF oDlgConsulta

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlgConsulta

   @ C(039),C(005) Say "Pesquisar consultas do módulo" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgConsulta

   @ C(048),C(005) ComboBox cLista Items aLista Size C(355),C(010) PIXEL OF oDlgConsulta on change CargaConsultas(1)

   @ C(179),C(005) Button "Incluir"  Size C(055),C(012) PIXEL OF oDlgConsulta ACTION( AbrConsulta("I", "") )
   @ C(179),C(063) Button "Alterar"  Size C(055),C(012) PIXEL OF oDlgConsulta ACTION( AbrConsulta("A", aConsultas[oConsultas:nAt,01]) )
   @ C(179),C(122) Button "Excluir"  Size C(055),C(012) PIXEL OF oDlgConsulta ACTION( AbrConsulta("E", aConsultas[oConsultas:nAt,01]) )
// @ C(179),C(181) Button "Duplicar" Size C(055),C(012) PIXEL OF oDlgConsulta
   @ C(179),C(323) Button "Sair"      Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( oDlgConsulta:End() )

   // Inicializa o Grid de Consultas
   oConsultas := TCBrowse():New( 080 , 005, 455, 145,,{"Relação de Consultas"}, {20,50,50,50},oDlgConsulta,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para o Grid
   oConsultas:SetArray(aConsultas) 
    
   // Monta a linha a ser exibina no Grid
   oConsultas:bLine := {||{aConsultas[oConsultas:nAt,01]}}
      
   oConsultas:Refresh()

   oConsultas:bHeaderClick := {|oObj,nCol| oConsultas:aArray := Ordenar(nCol,oConsultas:aArray),oConsultas:Refresh()}
   oConsultas:bLDblClick := {|| AbrConsulta("A", aConsultas[oConsultas:nAt,01]) } 

   ACTIVATE MSDIALOG oDlgConsultas CENTERED 

Return(.T.)

// ##########################################
// Função que abre a tela de Usuário Final ##
// ##########################################
Static Function ADVPL_USUARIO()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private kTitulo      := ""
   Private kTituloR     := ""   
   Private aLista       := {"Item01","Item02"}
   Private cLista
   Private aParametros  := {}
   Private aModulos     := {}
   Private cTQry        := ""
   Private kGrupo       := Space(10)
   Private cPesquisa    := Space(150)
   Private aData        := {}
   Private aHead        := {}
   Private aConsultas   := {}
   Private aVerifica    := {}
   Private aTipoCarac   := {}
   Private aTipoField   := {}
   Private aModelos     := {}
   Private aListax      := {}
   Private oListax

   Private oWindow         := Nil
   Private oGrpProd        := Nil
   Private oGrpFields      := Nil
   Private oGrpQuery       := Nil
   Private oGrpResult      := Nil
   Private cCmbPes         := Nil
   Private cCmbOpc         := Nil   
   Private cCmbPq          := Nil
   Private cCmbIt          := Nil
   Private oTBtnIncluir    := Nil
   Private oTBtnSalvar     := Nil

   Private oTBtnParametros := Nil
   Private oTBtnPermissoes := Nil
   Private oTBtnValidar    := Nil      
   Private oTBtnClose      := Nil
   Private oTBtnExQry      := Nil
   Private oTBtnExpQry     := Nil
   Private oTMuGetQry      := Nil
   Private oTGridField     := Nil
   Private oTGridResult    := Nil
   Private oMtrQuery       := Nil
   Private nMtrQuery       := Nil
   Private oTSay           := Nil
   Private oTSayTb         := Nil
   Private oTBitmap1       := Nil

   // Carrega os módulos do sustema Protheus
   aLista := {}

   Aadd(aLista, "00 - Selecione um Módulo" )
   Aadd(aLista, "01 - Ativo" )
   Aadd(aLista, "02 - Compras" )
   Aadd(aLista, "04 - Estoque/Custos" )
   Aadd(aLista, "05 - Faturamento" )
   Aadd(aLista, "06 - Financeiro" )
   Aadd(aLista, "07 - Gestão de Pessoal" )
   Aadd(aLista, "09 - Livros fiscais" )
   Aadd(aLista, "10 - Planejamento Controle Produção" )
   Aadd(aLista, "11 - Veículos" )
   Aadd(aLista, "12 - Controle de Loja" )
   Aadd(aLista, "13 - Call Center" )
   Aadd(aLista, "14 - Oficina" )
   Aadd(aLista, "16 - Ponto Eletrônico" )
   Aadd(aLista, "17 - Easy Import Control" )
   Aadd(aLista, "18 - Terminal de Consulta do Funcionário" )
   Aadd(aLista, "19 - Manutenção de Ativos" )
   Aadd(aLista, "20 - Recruramento e Seleção de Pessoal" )
   Aadd(aLista, "21 - Inspeção de Entradas" )
   Aadd(aLista, "22 - Metrologia" )
   Aadd(aLista, "23 - Front loja" )
   Aadd(aLista, "24 - Controle de Documentos" )
   Aadd(aLista, "26 - Treinamento" )
   Aadd(aLista, "28 - Gestão de Serviços" )
   Aadd(aLista, "29 - Easy Export Control" )
   Aadd(aLista, "30 - Easy Financing" )
   Aadd(aLista, "31 - Easy Accounting" )
   Aadd(aLista, "33 - Plano de Saúde" )
   Aadd(aLista, "34 - Contabilidade Gerencial" )
   Aadd(aLista, "35 - Medicina e Segurança do Trabalho" )
   Aadd(aLista, "36 - Controle de Não-Conformidade" )
   Aadd(aLista, "37 - Controle de Auditoria" )
   Aadd(aLista, "39 - OMS - Gestão de Distribuição" )
   Aadd(aLista, "40 - Cargso e Salários" )
   Aadd(aLista, "41 - Auto Peças" )
   Aadd(aLista, "42 - WMS - Gestão de Armazenagem" )
   Aadd(aLista, "43 - TMS - Gestão de Transporte" )
   Aadd(aLista, "44 - Gestão de Projetos" )
   Aadd(aLista, "45 - Controle de Direitos Autorais" )
   Aadd(aLista, "47 - PPAP" )
   Aadd(aLista, "48 - Réplica" )
   Aadd(aLista, "50 - Easy Dawback Control" )
   Aadd(aLista, "51 - Gestão Hospitalar" )
   Aadd(aLista, "53 - Avaliação e Pesquisa de Desempenho" )
   Aadd(aLista, "55 - Sistema de Fidelização e Análise de Crédito" )
   Aadd(aLista, "56 - Gestão Ambiental" )
   Aadd(aLista, "57 - Planejamento e Controle Orçamentário" )
   Aadd(aLista, "58 - Gerenciamento  de Pesquisa e Resultados" )
   Aadd(aLista, "59 - Gestão de Acervos" )
   Aadd(aLista, "64 - Processos Trabalhistas" )
   Aadd(aLista, "66 - Gestão de Riscos" )
   Aadd(aLista, "67 - Gestão Agrícola" )
   Aadd(aLista, "69 - Gestão de Contratos" )
   Aadd(aLista, "70 - Arquitetura Organizacional" )
   Aadd(aLista, "73 - CRM" )
   Aadd(aLista, "76 - Gestão Jurídica" )
   Aadd(aLista, "77 - Pré Faturamento de Serviços" )
   Aadd(aLista, "78 - Gestão de Frete Embarcador" )
   Aadd(aLista, "79 - Chão de Fábrica" )
   Aadd(aLista, "80 - Acessibilidade Visual" )
   Aadd(aLista, "81 - Monitoramento de Desempenho Logístico" )
   Aadd(aLista, "84 - TOTVS Autuomação Fiscal" )
   Aadd(aLista, "85 - Easy Suscoserv" )
   Aadd(aLista, "89 Promoção da Saúde" )

   // Carrega os módulos do sustema Protheus
   aModulos := {}

   Aadd(aModulos, "00 - Selecione um Módulo" )
   Aadd(aModulos, "01 - Ativo" )
   Aadd(aModulos, "02 - Compras" )
   Aadd(aModulos, "04 - Estoque/Custos" )
   Aadd(aModulos, "05 - Faturamento" )
   Aadd(aModulos, "06 - Financeiro" )
   Aadd(aModulos, "07 - Gestão de Pessoal" )
   Aadd(aModulos, "09 - Livros fiscais" )
   Aadd(aModulos, "10 - Planejamento Controle Produção" )
   Aadd(aModulos, "11 - Veículos" )
   Aadd(aModulos, "12 - Controle de Loja" )
   Aadd(aModulos, "13 - Call Center" )
   Aadd(aModulos, "14 - Oficina" )
   Aadd(aModulos, "16 - Ponto Eletrônico" )
   Aadd(aModulos, "17 - Easy Import Control" )
   Aadd(aModulos, "18 - Terminal de Consulta do Funcionário" )
   Aadd(aModulos, "19 - Manutenção de Ativos" )
   Aadd(aModulos, "20 - Recruramento e Seleção de Pessoal" )
   Aadd(aModulos, "21 - Inspeção de Entradas" )
   Aadd(aModulos, "22 - Metrologia" )
   Aadd(aModulos, "23 - Front loja" )
   Aadd(aModulos, "24 - Controle de Documentos" )
   Aadd(aModulos, "26 - Treinamento" )
   Aadd(aModulos, "28 - Gestão de Serviços" )
   Aadd(aModulos, "29 - Easy Export Control" )
   Aadd(aModulos, "30 - Easy Financing" )
   Aadd(aModulos, "31 - Easy Accounting" )
   Aadd(aModulos, "33 - Plano de Saúde" )
   Aadd(aModulos, "34 - Contabilidade Gerencial" )
   Aadd(aModulos, "35 - Medicina e Segurança do Trabalho" )
   Aadd(aModulos, "36 - Controle de Não-Conformidade" )
   Aadd(aModulos, "37 - Controle de Auditoria" )
   Aadd(aModulos, "39 - OMS - Gestão de Distribuição" )
   Aadd(aModulos, "40 - Cargso e Salários" )
   Aadd(aModulos, "41 - Auto Peças" )
   Aadd(aModulos, "42 - WMS - Gestão de Armazenagem" )
   Aadd(aModulos, "43 - TMS - Gestão de Transporte" )
   Aadd(aModulos, "44 - Gestão de Projetos" )
   Aadd(aModulos, "45 - Controle de Direitos Autorais" )
   Aadd(aModulos, "47 - PPAP" )
   Aadd(aModulos, "48 - Réplica" )
   Aadd(aModulos, "50 - Easy Dawback Control" )
   Aadd(aModulos, "51 - Gestão Hospitalar" )
   Aadd(aModulos, "53 - Avaliação e Pesquisa de Desempenho" )
   Aadd(aModulos, "55 - Sistema de Fidelização e Análise de Crédito" )
   Aadd(aModulos, "56 - Gestão Ambiental" )
   Aadd(aModulos, "57 - Planejamento e Controle Orçamentário" )
   Aadd(aModulos, "58 - Gerenciamento  de Pesquisa e Resultados" )
   Aadd(aModulos, "59 - Gestão de Acervos" )
   Aadd(aModulos, "64 - Processos Trabalhistas" )
   Aadd(aModulos, "66 - Gestão de Riscos" )
   Aadd(aModulos, "67 - Gestão Agrícola" )
   Aadd(aModulos, "69 - Gestão de Contratos" )
   Aadd(aModulos, "70 - Arquitetura Organizacional" )
   Aadd(aModulos, "73 - CRM" )
   Aadd(aModulos, "76 - Gestão Jurídica" )
   Aadd(aModulos, "77 - Pré Faturamento de Serviços" )
   Aadd(aModulos, "78 - Gestão de Frete Embarcador" )
   Aadd(aModulos, "79 - Chão de Fábrica" )
   Aadd(aModulos, "80 - Acessibilidade Visual" )
   Aadd(aModulos, "81 - Monitoramento de Desempenho Logístico" )
   Aadd(aModulos, "84 - TOTVS Autuomação Fiscal" )
   Aadd(aModulos, "85 - Easy Suscoserv" )
   Aadd(aModulos, "89 Promoção da Saúde" )

   // Verifica se existe a pasta advpltools na aplicação. Caso não exista, será criada
   If !ExistDir( "\advpltools" )

      nRet := MakeDir( "\advpltools" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta advpltools. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // Envia para a função que carrega o grid com todas as consultas da pasta advpltools
   CargaConsultas(0)

   Private oDlgConsulta

   DEFINE MSDIALOG oDlgConsulta TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(570),C(910) PIXEL

   @ C(005),C(005) Jpeg FILE "advpltools.png" Size C(107),C(032) PIXEL NOBORDER OF oDlgConsulta

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlgConsulta

   @ C(039),C(005) Say "Pesquisar consultas do módulo" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgConsulta

   @ C(048),C(005) ComboBox cLista Items aLista Size C(355),C(010) PIXEL OF oDlgConsulta on change CargaConsultas(1)

   @ C(179),C(005) Button "Excel"      Size C(035),C(012) PIXEL OF oDlgConsulta ACTION( Executausuario(aConsultas[oConsultas:nAt,01], 1) )
   @ C(179),C(040) Button "Relatório"  Size C(035),C(012) PIXEL OF oDlgConsulta ACTION( Executausuario(aConsultas[oConsultas:nAt,01], 2) )
   @ C(179),C(075) Button "Grid"       Size C(035),C(012) PIXEL OF oDlgConsulta ACTION( Executausuario(aConsultas[oConsultas:nAt,01], 3) )
   @ C(179),C(111) Button "Em Arquivo" Size C(035),C(012) PIXEL OF oDlgConsulta ACTION( Executausuario(aConsultas[oConsultas:nAt,01], 4) )
   @ C(179),C(323) Button "Sair"       Size C(037),C(012) PIXEL OF oDlgConsulta ACTION( oDlgConsulta:End() )

   // Inicializa o Grid de Consultas
   oConsultas := TCBrowse():New( 080 , 005, 455, 145,,{"Relação de Consultas"}, {20,50,50,50},oDlgConsulta,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para o Grid
   oConsultas:SetArray(aConsultas) 
    
   // Monta a linha a ser exibina no Grid
   oConsultas:bLine := {||{aConsultas[oConsultas:nAt,01]}}
      
   oConsultas:Refresh()

// oConsultas:bHeaderClick := {|oObj,nCol| oConsultas:aArray := Ordenar(nCol,oConsultas:aArray),oConsultas:Refresh()}
// oConsultas:bLDblClick := {|| AbrConsulta("A", aConsultas[oConsultas:nAt,01]) } 

   ACTIVATE MSDIALOG oDlgConsultas CENTERED 

Return(.T.)

// ########################################################################################################
// Função que pesquisa dados da consulta selecionada pelo usuário e a executa conforme opção selecionada ##
// ########################################################################################################
Static Function Executausuario(Par_arquivo, Par_Opcao)
 
   Local nContar       := 0
   Local lPodeExecutar := .F.
   
   aParametros := {}
   cTQry       := ""
   kGrupo      := Space(10)
   cPesquisa   := Space(150)
   aData       := {}
   aHead       := {}
   aVerifica   := {}
   aTipoCarac  := {}
   aTipoField  := {}
   aListax     := {}

   If Empty(Alltrim(Par_arquivo))
      MsglAlert("Nenhuma consulta selecionada para visualização.")
      Return(.T.)
   Endif

   // Inicializa as variáveis das perguntas
   For ncontar = 1 to 20
       j := Strzero(nContar,2)
       MV_PAR&j := ""
   Next nContar

   // Envia para a função que pesquisa dados da consulta selecionda para execução
   le_arquivo(par_arquivo)
   
   // Verifica se usuário possui autorização de execução da consulta selecionada
   If Alltrim(Upper(__cUserID)) == "000000"
      lPodeExecutar := .T.
   Else   
      lPodeExecutar := .F.
      For nContar = 1 to Len(aParametros)
          If aParametros[nContar,01] == "[A]"
             If Alltrim(Upper(aParametros[nContar,03])) == Alltrim(Upper(__cUserID))
                lPodeExecutar := .T.
                Exit
             Endif
          Endif
      Next nContar          
   Endif
   
   If lPodeexecutar == .F.
      MsgStop("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Você não possui permissão para executar esta consulta." + chr(13) + chr(10) + "Entre em contato com o administrador solicitando permissão.")
      Return(.T.)
   Endif

   // Envia para a função que executa a pesquisa selecionada
   RodaQuery()

   If Len(aConsultas) == 0
      MsgAlert("Não existem dados a serem visualizados para esta pesquisa.")
      Return(.T.)
   Endif

   Do Case
      // Excel
      Case Par_Opcao == 1
           GeraExcel(1)

      // Relatório
      Case Par_Opcao == 2
           AbrRelPadraoProtheus(1)

      // Grid
      Case Par_Opcao == 3
           ExpandeGrid()

      // Em Arquivo
      Case Par_Opcao == 4
           GeraTXT(1)

   EndCase

Return(.T.)      

// ######################################################
// Função que visualiza o resultado no formato de grid ##
// ######################################################
Static Function ExpandeGrid()

   // 1 == Consulta
   // 2 - Resultado

   Local cMemo2  := ""
   Local oMemo2
   Local nContar := 0

   Private aDataPes   := {}
   Private cStringPes := "Filtro(s) Utilizado(s): " + chr(13) + chr(10) + chr(13) + chr(10)

   Private aCamposExp := {}
   Private aOperacoes := {"Selecione Operação", "Igual a", "Diferente de", "Menor que", "Menor ou igual a", "Maior que", "Maior ou Igual a", "Contém a expressão", "Não contém a expressão" }
   Private aOrdenaExp := {}
   Private cCamposExp
   Private cOperacoes
   Private cOrdenaExp

   Private cExpressao := Space(254)
   Private cGet1

   // Guarda o resultado original
   For nContar = 1 to Len(aData)
       aAdd( aDataPes, aData[nContar])
   Next nContar    

   // Carrega o combo dos campos para seleção da pesquisa
   aAdd( aCamposExp, "Selecione Campo" )
   aAdd( aOrdenaExp, "Selecione Campo" )

   For nContar = 1 to Len(aHead)
       aAdd( aCamposExp, aHead[nContar] )
       aAdd( aOrdenaExp, aHead[nContar] )       
   Next nContar    

   Private oDlgE

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgE TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(634),C(1170) PIXEL

   @ C(005),C(003) Jpeg FILE "advpltools.png" Size C(098),C(022) PIXEL NOBORDER OF oDlgE

   @ C(028),C(003) GET oMemo2 Var cMemo2 MEMO Size C(488),C(001) PIXEL OF oDlgE

   @ C(034),C(005) Say "Campos"      Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(034),C(085) Say "Operadores"  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(034),C(170) Say "Expressão"   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(034),C(425) Say "Ordenar por" Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(043),C(005) ComboBox cCamposExp Items aCamposExp Size C(075),C(010) PIXEL OF oDlgE
   @ C(043),C(085) ComboBox cOperacoes Items aOperacoes Size C(080),C(010) PIXEL OF oDlgE
   @ C(043),C(425) ComboBox cOrdenaExp Items aOrdenaExp Size C(065),C(010) PIXEL OF oDlgE ON CHANGE OrdenaPes()

   @ C(043),C(170) MsGet    oGet1     Var   cExpressao Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(041),C(344) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlgE ACTION( PsqExpressao() )
   @ C(041),C(382) Button "Limpar Filtro" Size C(037),C(012) PIXEL OF oDlgE ACTION( LimpaExpande() )
	
   // Grid de resultados
   oTGridResult:= GridTools():New(oGrpResult, aDataPes, aHead, 075,003, 627,190)

   @ C(212),C(003) Button "Filtros" Size C(048),C(012) PIXEL OF oDlgE ACTION( MsgAlert(cStringPes) )
   @ C(212),C(445) Button "Voltar"  Size C(048),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)              

// ###################################################
// Função que executa a pesquisa para usuário final ##
// ###################################################
Static Function RodaQuery()

   MsgRun("Aguarde! Executando pesquisa selecionada ...", "ADVPL Tools",{|| ExecQuery(cTQry, 1) })

Return(.T.)

// #################################################################
// Função que pesquisa as consultas conforme o módulo selecionado ##
// #################################################################
Static Function CargaConsultas(_Tipo)

   Local aFiles
   Local aSizes

   aConsultas := {}

   // Carrega o array aPesquisas com os select da pasta advpltools
   ADir("advpltools\*.*", aFiles, aSizes)   
   
   // Carrega o array aArquivos para display no List
   nRegua := 0
   nCount := Len( aFiles )
   cXML   := ""

   For nContar := 1 to nCount

       If _Tipo == 0
          aAdd( aConsultas, { aFiles[nContar] } )
       Else   
          If Substr(cLista,01,02) == "00"
             aAdd( aConsultas, { aFiles[nContar] } )
          Else
             If Substr(aFiles[nContar],01,02) == Substr(cLista,01,02)
                aAdd( aConsultas, { aFiles[nContar] } )
             Endif
          Endif      
       Endif   

   Next nContar

   If Len(aConsultas) == 0
      aAdd( aConsultas, { "NÃO EXISTEM CONSULTAS A SEREM VISUALIZADAS PARA ESTA PESQUISA." } )
   Endif
 
   If _Tipo == 0
      Return(.T.)
   Endif   

   // Seta vetor para o Grid
   oConsultas:SetArray(aConsultas) 
   oConsultas:bLine := {||{aConsultas[oConsultas:nAt,01]}}
   oConsultas:Refresh()

Return(.T.)

// #################################################
// Função que Ordena a coluna selecionada no grid ##
// #################################################
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

Static Function AbrConsulta(par_Operacao, par_Arquivo)

   Local cArqExclui := ""
 
   If par_operacao == "I"
      MsgRun("Aguarde! Preparando inclusão de consulta ...", "Manutenção de Consulta",{|| AltConsulta(par_Operacao, par_Arquivo) })
   Else                                    
      If par_operacao == "A"
         MsgRun("Aguarde! Carregando consulta selecionada ...", "Manutenção de Consulta",{|| AltConsulta(par_Operacao, par_Arquivo) })
      Else    
         If MsgYesNo("Deseja realmente excluir a consulta: " + Alltrim(par_Arquivo))
                 
            cArqExclui := "\advpltools\" + par_Arquivo

            IF FERASE(cArqExclui) <> -1
               
               // Envia para a função que carrega o grid com todas as consultas da pasta advpltools
               CargaConsultas(1)

               MsgAlert("Arquivo excluído com sucesso.")
            
            Else
            
               MsgAlert("Atenção! Houve erro ao ser excluído o arquivo " + Alltrim(Par_Arquivo) + ". Tente novamente.")

               Return(.T.)
               
            Endif
                     
         Endif
      Endif      
   Endif

Return(.T.)

// Função que abre janela de manutenção da consulta
Static Function AltConsulta(par_Operacao, par_Arquivo)

   Local lChumba   := .F.
   Local lEdiat    := .F.

   Local cMemo1	   := ""
   Local cMemo2	   := ""

   Local oMemo1
   Local oMemo2

   Private kTitulo   := ""
   Private kTituloR  := ""   

   Private cUsuarios := Space(250)
   Private aTabelas  := {}
   Private aModulos  := {}
   Private cComboBx1
   Private cComboBx2
   Private cPesquisa := Space(150)
   Private cOperacao := Space(015)
   Private oGet1
   Private oGet2

   Private aParametros     := {}

   Private aData           := {}
   Private aHead           := {}
   Private aTipoCarac      := {}
   Private aTipoField      := {}
   Private aModelos        := {}

   Private oWindow         := Nil
   Private oGrpProd        := Nil
   Private oGrpFields      := Nil
   Private oGrpQuery       := Nil
   Private oGrpResult      := Nil
   Private cCmbPes         := Nil
   Private cCmbOpc         := Nil   
   Private cCmbPq          := Nil
   Private cCmbIt          := Nil
   Private oTBtnIncluir    := Nil
   Private oTBtnSalvar     := Nil

   Private oTBtnParametros := Nil
   Private oTBtnPermissoes := Nil
   Private oTBtnValidar    := Nil      
   Private oTBtnClose      := Nil
   Private oTBtnExQry      := Nil
   Private oTBtnExpQry     := Nil
   Private oTMuGetQry      := Nil
   Private oTGridField     := Nil
   Private oTGridResult    := Nil
   Private oMtrQuery       := Nil
   Private nMtrQuery       := Nil
   Private oTSay           := Nil
   Private oTSayTb         := Nil
   Private oTBitmap1       := Nil

   Private aPesquisas   := {}
   Private aItemsCmb    := {}
   Private oTFontLabel1 := TFont():New('Arial',,-24,.T.)
   Private oTFontlb     := TFont():New('Arial',,-16,.T.)
   Private oTFontBt     := TFont():New('Arial',,-11,.T.)
   Private oTFontQry    := TFont():New('Arial',,-18,.T.)
   Private oTFontCNEW   := TFont():New('Courier New',,-16,.T.)

   Private cTQry        := ""
   Private cTQry2       := ""
   Private cHeightS     := ""
   Private cWidthS      := ""
   Private cValTb       := ""

   Private aFields      := {}
   Private aHeader      := {}

   Private aVerifica    := {}

   Private aListax := {}
   Private oListax

   Private kGrupo       := Space(10)

   Private kConfGeral   := ""
   Private kIdentifica  := ""
   Private kLogomarca   := ""
   Private kCabecalho   := ""
   Private kQuebras     := ""
   Private kDetalhes    := ""
   Private kTotalizador := ""
   Private kRodape      := ""

   Private oDlg

   // Verifica se foi selecionado um arquivo para abertura
   If par_Operacao == "I"
   Else
      If Empty(Alltrim(par_Arquivo))
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum arquivo selecionado para visualização." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif
   Endif

   // Carrega o combo de tabelas
   DbSelectArea("SX2")
   DbSetOrder(1)

   aTabelas := {}

   While !SX2->( EOF() )
      Aadd(aTabelas, SX2->X2_CHAVE + " - " + SX2->X2_NOME )
      DbSkip()
   EndDo

   If Len(aTabelas) == 0
      Aadd(aTabelas, "      " )      
   Endif

   //SX2->(DbCloseArea())

   // Carrega os módulos do sustema Protheus
   aModulos := {}

   Aadd(aModulos, "00 - Selecione um Módulo" )
   Aadd(aModulos, "01 - Ativo" )
   Aadd(aModulos, "02 - Compras" )
   Aadd(aModulos, "04 - Estoque/Custos" )
   Aadd(aModulos, "05 - Faturamento" )
   Aadd(aModulos, "06 - Financeiro" )
   Aadd(aModulos, "07 - Gestão de Pessoal" )
   Aadd(aModulos, "09 - Livros fiscais" )
   Aadd(aModulos, "10 - Planejamento Controle Produção" )
   Aadd(aModulos, "11 - Veículos" )
   Aadd(aModulos, "12 - Controle de Loja" )
   Aadd(aModulos, "13 - Call Center" )
   Aadd(aModulos, "14 - Oficina" )
   Aadd(aModulos, "16 - Ponto Eletrônico" )
   Aadd(aModulos, "17 - Easy Import Control" )
   Aadd(aModulos, "18 - Terminal de Consulta do Funcionário" )
   Aadd(aModulos, "19 - Manutenção de Ativos" )
   Aadd(aModulos, "20 - Recruramento e Seleção de Pessoal" )
   Aadd(aModulos, "21 - Inspeção de Entradas" )
   Aadd(aModulos, "22 - Metrologia" )
   Aadd(aModulos, "23 - Front loja" )
   Aadd(aModulos, "24 - Controle de Documentos" )
   Aadd(aModulos, "26 - Treinamento" )
   Aadd(aModulos, "28 - Gestão de Serviços" )
   Aadd(aModulos, "29 - Easy Export Control" )
   Aadd(aModulos, "30 - Easy Financing" )
   Aadd(aModulos, "31 - Easy Accounting" )
   Aadd(aModulos, "33 - Plano de Saúde" )
   Aadd(aModulos, "34 - Contabilidade Gerencial" )
   Aadd(aModulos, "35 - Medicina e Segurança do Trabalho" )
   Aadd(aModulos, "36 - Controle de Não-Conformidade" )
   Aadd(aModulos, "37 - Controle de Auditoria" )
   Aadd(aModulos, "39 - OMS - Gestão de Distribuição" )
   Aadd(aModulos, "40 - Cargso e Salários" )
   Aadd(aModulos, "41 - Auto Peças" )
   Aadd(aModulos, "42 - WMS - Gestão de Armazenagem" )
   Aadd(aModulos, "43 - TMS - Gestão de Transporte" )
   Aadd(aModulos, "44 - Gestão de Projetos" )
   Aadd(aModulos, "45 - Controle de Direitos Autorais" )
   Aadd(aModulos, "47 - PPAP" )
   Aadd(aModulos, "48 - Réplica" )
   Aadd(aModulos, "50 - Easy Dawback Control" )
   Aadd(aModulos, "51 - Gestão Hospitalar" )
   Aadd(aModulos, "53 - Avaliação e Pesquisa de Desempenho" )
   Aadd(aModulos, "55 - Sistema de Fidelização e Análise de Crédito" )
   Aadd(aModulos, "56 - Gestão Ambiental" )
   Aadd(aModulos, "57 - Planejamento e Controle Orçamentário" )
   Aadd(aModulos, "58 - Gerenciamento  de Pesquisa e Resultados" )
   Aadd(aModulos, "59 - Gestão de Acervos" )
   Aadd(aModulos, "64 - Processos Trabalhistas" )
   Aadd(aModulos, "66 - Gestão de Riscos" )
   Aadd(aModulos, "67 - Gestão Agrícola" )
   Aadd(aModulos, "69 - Gestão de Contratos" )
   Aadd(aModulos, "70 - Arquitetura Organizacional" )
   Aadd(aModulos, "73 - CRM" )
   Aadd(aModulos, "76 - Gestão Jurídica" )
   Aadd(aModulos, "77 - Pré Faturamento de Serviços" )
   Aadd(aModulos, "78 - Gestão de Frete Embarcador" )
   Aadd(aModulos, "79 - Chão de Fábrica" )
   Aadd(aModulos, "80 - Acessibilidade Visual" )
   Aadd(aModulos, "81 - Monitoramento de Desempenho Logístico" )
   Aadd(aModulos, "84 - TOTVS Autuomação Fiscal" )
   Aadd(aModulos, "85 - Easy Suscoserv" )
   Aadd(aModulos, "89 Promoção da Saúde" )

   // Carrega o array aFileds e aHeader para display da primeira tabela
   LoadFields(aTabelas[01],0)

   // Envia para a função que lê os dados do arquivo selecionado em caso de alteração e exclusão
   If par_Operacao == "I"
   Else
      le_arquivo(par_arquivo)
   Endif

   // Carrega a variável Operacao
   Do Case
      Case par_Operacao == "I"
           lEdita := .T.
           cOperacao := "INCLUSÃO"
      Case par_Operacao == "A"
           lEdita := .F.
           cOperacao := "ALTERAÇÃO"
      Case par_Operacao == "E"
           lEdita := .F.
           cOperacao := "EXCLUSÃO"
   EndCase        

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(634),C(1170) PIXEL

   @ C(005),C(003) Jpeg FILE "advpltools.png" Size C(098),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(003) GET oMemo2 Var cMemo2 MEMO Size C(488),C(001) PIXEL OF oDlg

   @ C(031),C(005) Say "Arquivo de Consulta"          Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(221) Say "Módulo"                       Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(445) Say "Operação"                     Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(005) Say "Tabelas do Sistema"           Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(052),C(141) Say "Query"                        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(123),C(141) Say "Resultado"                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(071),C(005) Say "Campos da tabela selecionada" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(005) MsGet    oGet1     Var   cPesquisa Size C(210),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEdita
   @ C(040),C(221) ComboBox cComboBx2 Items aModulos  Size C(220),C(010)                              PIXEL OF oDlg
   @ C(040),C(445) MsGet    oGet2     Var   cOperacao Size C(048),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(060),C(005) ComboBox cComboBx1 Items aTabelas  Size C(131),C(010)                              PIXEL OF oDlg ON CHANGE LoadFields(cComboBx1,1)

   If par_Operacao == "I"
      cTQry := "SELECT < campos > " + chr(13) + chr(10) + "    FROM < Tabelas > " + chr(13) + chr(10) + "      WHERE < Condições > " + Chr(13) + chr(10) + "   GROUP BY < Campos de Agrupamentos > " + Chr(13) + chr(10) + " ORDER BY < Campos de Ordenação >"
   Endif
      
   oTMuGetQry := tMultiget():New( 077, 180, {| u | if( pCount() > 0, cTQry := u, cTQry ) },oGrpQuery, 450, 80,oTFontCNEW ,,,,, .T. )
   oTMuGetQry:EnableVScroll(.T.)

   @ C(212),C(005) Button "Perguntas"     Size C(041),C(012) PIXEL OF oDlg ACTION( ABRPerguntas() )
   @ C(212),C(050) Button "Acessos"       Size C(041),C(012) PIXEL OF oDlg ACTION( PermiteAcesso() )
   @ C(212),C(093) Button "Salvar"        Size C(041),C(012) PIXEL OF oDlg ACTION( SalvaQuery(par_Operacao) )
   @ C(212),C(142) Button "Executar"      Size C(035),C(012) PIXEL OF oDlg ACTION( ExecQuery(cTQry, 0) )

   @ C(212),C(185) Button "Grid"          Size C(035),C(012) PIXEL OF oDlg ACTION( Expande(2) )              When Len(aData) <> 0      
   @ C(212),C(220) Button "Relatório"     Size C(035),C(012) PIXEL OF oDlg ACTION( GeraRelPadrao() )         When Len(aData) <> 0
   @ C(212),C(255) Button "Excel"         Size C(035),C(012) PIXEL OF oDlg ACTION( GeraExcel(0) )            When Len(aData) <> 0
   @ C(212),C(290) Button "Em Arquivo"    Size C(035),C(012) PIXEL OF oDlg ACTION( GeraTXT(0) )              When Len(aData) <> 0

   @ C(212),C(335) Button "CFG Relatório" Size C(035),C(012) PIXEL OF oDlg ACTION( AbrRelPadraoProtheus(0) ) When Len(aData) <> 0

   @ C(212),C(383) Button "Expande Query" Size C(048),C(012) PIXEL OF oDlg ACTION( Expande(1) )      
   @ C(212),C(445) Button "Voltar"        Size C(048),C(012) PIXEL OF oDlg ACTION( FechaDesing(par_Operacao) )

   // Grid com os campos da tabela selecionada
   oTGridField:= GridTools():New(oGrpFields, aFields, aHeader, 090, 005, 167, 175)  &&195 

   // Grid do resultado da pesquisa
   oTGridResult:= GridTools():New(oGrpResult, aData, aHead, 165,180, 450,100)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                      

// ##########################################################################
// Função que fecha a tela do desing perguntando se deseja sair sem salvar ##
// ##########################################################################
Static Function FechaDesing(XKOPERACAO)  
                                      
    If XKOPERACAO == "A"
       SalvaQuery(XKOPERACAO)   
    Endif

    oDlg:End() 

   // Envia para a função que carrega o grid com todas as consultas da pasta advpltools
   CargaConsultas(1)
   
Return(.T.)            

// ###########################
// Função que salva a query ##
// ###########################
Static Function SalvaQuery(_Operacao)  

   Local cString   := ""
   Local cGravaArq := "" 
   
   // Gera consistência dos dados antes da gravação dos dados
   
   // Consiste o título da quary
   If Empty(Alltrim(cPesquisa))
      MsgAlert("Título da query deve ser informada.")
      Return(.T.)
   Endif
   
   // Consiste a informação do módulo
   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Módulo não selecionado.")
      Return(.T.)
   Endif

   // Consiste se query foi informada
   If Empty(Alltrim(cTqry))
      MsgAlert("Query não informada.")
      Return(.T.)
   Endif

   cGravaArq := "\advpltools\" + Substr(cComboBx2,01,02) + " - " + Alltrim(cPesquisa) + ".TXT"

   // Grava as informações no array aParametros antes da gravação
   GravaParametros("[T]", 1, Alltrim(cPesquisa))
   GravaParametros("[S]", 1, Alltrim(Strtran(cTqry, chr(13), "<ENTER>")))
   GravaParametros("[M]", 1, Substr(cComboBx2,01,02))
   GravaParametros("[G]", 1, Alltrim(kGrupo))

   // Elabora a string de gravação do arquivo da consulta
   cString := ""
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[00"
          Loop
       Endif
       cString += aParametros[nContar,01] + "[" + Strzero(aParametros[nContar,02],02) + "]" + aParametros[nContar,03] + "[F]" + chr(13) + chr(10)
   Next nContar

   // Grava o arquivo
   If _Operacao == "I"

      If File(cGravaArq)
      
         If (MsgYesNo("Arquivo já existe na pasta. Deseja sobrescrever o arquivo?","Atenção!"))

            // Gera o arquivo XML para o caminho informado
            nHdl := fCreate(cGravaArq)
            fWrite (nHdl, cString ) 
            fClose(nHdl)

            oDlg:End()
            
         Else
         
            Return(.T.)
         
         Endif
         
      Else
         
         // Gera o arquivo XML para o caminho informado
         nHdl := fCreate(cGravaArq)
         fWrite (nHdl, cString ) 
         fClose(nHdl)

         oDlg:End()

      Endif            

   Else
   
      // Gera o arquivo XML para o caminho informado
      nHdl := fCreate(cGravaArq)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      oDlg:End()
      
   Endif

   // Envia para a função que carrega o grid com todas as consultas da pasta advpltools
   CargaConsultas(1)
   
Return(.T.)      

// Função que lê os dados do arquivo selecionado
Static Function le_arquivo(par_arquivo)

   Local _Arquivo := "\advpltools\" + Alltrim(par_arquivo)

   If Empty(Alltrim(par_arquivo))
      Return(.T.)
   Endif

   If !File(_Arquivo)
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo selecionado inexistente.")
      Return(.T.)
   Endif

   // Abre o arquivo selecionado
   nHandle := FOPEN(Alltrim(_Arquivo), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
   Else

      // Lê o tamanho total do arquivo
      nLidos := 0
      FSEEK(nHandle,0,0)
      nTamArq := FSEEK(nHandle,0,2)
      FSEEK(nHandle,0,0)

      // Lê todos os Registros
      xBuffer:=Space(nTamArq)
      FREAD(nHandle,@xBuffer,nTamArq)
 
      cConteudo := ""
      aConsulta := {}

      xBuffer   := StrTran(Strtran(Strtran(xBuffer, chr(13), ""), chr(10), ""), "[F]", chr(9))

      For nContar = 1 to Len(xBuffer)

          If Substr(xBuffer, nContar, 1) <> CHR(9)

             cConteudo := cConteudo + Substr(xBuffer, nContar, 1)

          Else

             aAdd( aParametros, { Substr(cConteudo,01,03)          ,;
                                  Int(Val(Substr(cConteudo,05,02))),;
                                  Substr(cConteudo,08) }) 

             cConteudo := ""

          Endif

      Next nContar    
   
   Endif

   FCLOSE(nHandle)

   // Carrega o Título da consulta
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[T]"
          cPesquisa := aParametros[nContar,03]
          Exit
       Endif
   Next nContar          

   // Carrega o comando SQL
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[S]"
          cTQry     := Strtran(aParametros[nContar,03], "<ENTER>", chr(13) + chr(10))
          Exit
       Endif
   Next nContar          

   // Carrega o módulo da consulta
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[M]"
          _Modulo   := Alltrim(aParametros[nContar,03])
                       
          // Posiciona o módulo no combobox
          For xModulo = 1 to Len(aModulos)
              If Substr(aModulos[xModulo],01,02) == _Modulo
                 cComboBx2 := aModulos[xModulo]
                 Exit
              Endif
          Next xModulo       

          Exit

       Endif
   Next nContar

   // Carrega o grupo de perguntas da consulta
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[G]"
          kGrupo := Alltrim(aParametros[nContar,03])
          Exit
       Endif
   Next nContar          

Return(.T.)      

// Função que carrega os campos da tabela selecionada
Static Function LoadFields(cRotine,cMostra)

   aFields := {}
   aHeader := {}

   If Empty(Alltrim(cRotine))
      Return(.T.)
   Endif   

   DbSelectArea("SX3")
   DbSetOrder(1)

   If (DbSeek(Alltrim(Substr(cRotine,01,03))))
  	  While Alltrim(SX3->X3_ARQUIVO) == Alltrim(Substr(cRotine,01,03))
	     Aadd(aFields,{SX3->X3_ARQUIVO, SX3->X3_CAMPO, SX3->X3_TITULO })
		 DbSkip()
  	  EndDo
   End

   Aadd(aHeader,"Tabela")
   Aadd(aHeader,"Campo")
   Aadd(aHeader,"Descrição")

   If cMostra == 0
      Return(.T.)
   Endif   

   oTGridField:= GridTools():New(oGrpFields, aFields, aHeader, 090, 005, 167, 175)

Return

// #######################################
// Função que executa a query informada ##
// #######################################
Static Function ExecQuery(cQuery, _TipoExecuta)

   Local cQry         := cQuery
   Local aFields      := {}
   Local lContinue    := .T.
   Local nContar      := 0
   Local nlaco        := 0
   Local lExisteCampo := .F.

   aData       := {}
   aHead       := {}
   aTipoCarac  := {}
   aTipoField  := {}
   aModelos    := {}

   oMtrQuery := Nil

   If _TipoExecuta == 0
      If (Empty(cQry))
         lContinue := .F.
	     MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Consulta a ser gerada está vazia. Informe SQL a ser executado.")
         Return(.T.)
      Endif
   Endif   

   // Adiciona a pesquisa a coluna final
// cQry := SUBSTR(CTQRY,1,INT(VAL(U_P_OCCURS(CTQRY,"FROM",2)))-1) + ", '' AS FINAL " +   SUBSTR(CTQRY, INT(VAL(U_P_OCCURS(CTQRY,"FROM",2))))

   kTitulo  := ""
   kTitulo  := Alltrim(cPesquisa) + chr(13) + chr(10)

   kTituloR := ""

   // Inicializa as variáveis das perguntas
   For ncontar = 1 to 20
       j := Strzero(nContar,2)
       MV_PAR&j := ""
   Next nContar

   // Exibe a tela de parâmetros
   If U_P_OCCURS(cQry, "MV_P", 1) <> 0

      If !Empty(Alltrim(kGrupo))

         // Abre tela de parâmetros
         If !Pergunte( Alltrim(kGrupo), .T. )
            Return(.T.)
         Endif   

         // Carrega as perguntas para o array aVerifica
         aVerifica := {}
         dbSelectArea("SX1")
         If dbSeek(Alltrim(kGrupo))
            While Alltrim(SX1->X1_GRUPO) == Alltrim(kGrupo) .AND. !SX1->(EOF())
               aAdd( aVerifica, { Alltrim(SX1->X1_GRUPO), SX1->X1_ORDEM, SX1->X1_PERGUNT, SX1->X1_TIPO, SX1->X1_TAMANHO, SX1->X1_DECIMAL } )
               SX1->(dbSkip())
            EndDo
         Endif
  
         lVazio := .F.
      
         For nContar = 1 to Len(aVerifica)
             j := Strzero(nContar,2)
             Do Case
                Case VALTYPE(MV_PAR&j) == "C"
                     If Empty(Alltrim(MV_PAR&J))
                        lVazio := .T.
                        Exit
                     Else
                        kTitulo  += aVerifica[nContar,03] + " " + MV_PAR&J + chr(13) + chr(10)
                        kTituloR += Alltrim(aVerifica[nContar,03]) + " " + Alltrim(MV_PAR&J) + " "
                     Endif
                Case VALTYPE(MV_PAR&j) == "D"
                     If Empty(MV_PAR&J)
                        lVazio := .T.
                        Exit
                     Else
                        kTitulo  += aVerifica[nContar,03] + " " + Dtoc(MV_PAR&J) + chr(13) + chr(10)
                        kTituloR += Alltrim(aVerifica[nContar,03]) + " " + Dtoc(MV_PAR&J) + " "
                     Endif
                Case VALTYPE(MV_PAR&j) == "N"
                     If MV_PAR&J == 0
                        lVazio := .T.
                        Exit
                     Else
                        kTitulo  += aVerifica[nContar,03] + " " + str(MV_PAR&J) + chr(13) + chr(10)
                        kTituloR += Alltrim(aVerifica[nContar,03]) + " " + str(MV_PAR&J) + " "
                     Endif
             EndCase
         Next nContar
      
         If lVazio == .T.
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Comando não será executado pois existem parâmetros não preenchidos." + chr(13) + chr(10) + chr(13) + Chr(10) + "Verifique parâmetros!")    
            Return(.T.)
         Endif
         
      Endif

   EndIf
   
   // Executa a string
   If Empty(Alltrim(kGrupo))
   Else

      If U_P_OCCURS(cQry, "MV_P", 1) <> 0
      
         // Caracter
         For nContar = 1 to 20
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "C"
                If !Empty(Alltrim(MV_PAR&j))
                   cQry := StrTran(cQry, "#MV_PAR" + j, "'" + MV_PAR&j + "'")
                Endif
             Endif
         Next nContar

         // Data
         For nContar = 1 to 20
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "D"
                If !Empty(MV_PAR&j)
                   cQry := StrTran(cQry, "#MV_PAR" + j, Dtos(MV_PAR&j))
                Endif
             Endif
         Next nContar

         // Numérico
         For nContar = 1 to 20
             j := Strzero(nContar,2)
             If VALTYPE(MV_PAR&j) == "N"
                If MV_PAR&j <> 0
                   cQry := StrTran(cQry, "#MV_PAR" + j, Str(MV_PAR&j))
                Endif
             Endif
         Next nContar
         
      Endif   

   Endif

   // Executa o Sql
   If TcSQLExec(cQry) < 0
      lContinue := .F.
      MsgAlert(TCSQLError())
      Return(.T.)
   EndIf

   If (!lContinue)
      oTGridResult:ClearRows()
   EndIf

   If (lContinue)
   	  TcQuery cQry New Alias "TMP_QRY"

	  nRegs := 0

	  Count To nRegs

      If nRegs == 0
         MsgAlert("Não existem dados a serem visualizados para esta consulta.")
         TMP_QRY->(DbCloseArea())
         Return(.T.)
      Endif   

	  DbSelectArea("TMP_QRY")
	  TMP_QRY->(DbGoTop())

//	  nMtrQuery := nRegs
  	  // oMtrQuery:SetTotal()

	  nContTot := 0

      If _TipoExecuta == 0
         oMtrQuery := TMeter():New(067,230,{|u|if(Pcount()>0,nMtrQuery:=u,nMtrQuery)},nMtrQuery,oWindow,400,30,,.T.)
         oMtrQuery:Set(0)
      Endif   

	  For ix:= 1 To TMP_QRY->(FCount())
	  	  Aadd(aHead,Field(ix))
	  Next

	  While ! Eof()

	     aFields    := {}
         aTipoCarac := {}

		 For ix:= 1 To Len(aHead)

		 	 cFieldValue := "TMP_QRY->"+aHead[ix] + Space(30)
			 Aadd(aFields,StringType(&cFieldValue))

             // Carrega o array aTipoField com as características dos campos

             nConteudoCam := &cFieldValue

             Do Case
                // Se campo for caracter
                Case ValType(&cFieldValue) == "C"
                     nInteiro := Len(nConteudoCam)
                     nDecimal := 0
                     nMascara := "@!"

                // Se campo for data
                Case ValType(&cFieldValue) == "D"
                     nInteiro     := Len(nConteudoCam)
                     nDecimal     := 0
                     nMascara     := "@D"

                // Se campo for numérico
                Case ValType(&cFieldValue) == "N"
                     If U_P_OCCURS(Alltrim(Str(nConteudoCam)), ".", 1) == 0
                        nInteiro := Len(Alltrim(Str(nConteudoCam)))
                        nDecimal := 0
                        nMascara := "@E " + Replicate("9", nInteiro)
                     Else
                        nSepararCam := Alltrim(Str(nConteudoCam)) + "."
                        nInteiro := Len(U_P_CORTA(nSepararCam, ".", 1))
                        nDecimal := Len(U_P_CORTA(nSepararCam, ".", 2))
//                      nMascara := "@E " + Replicate("9", nInteiro) + "." + Replicate("9", nDecimal)
                        nMascara := "@E 99999999999.99"

                     Endif
             EndCase       
                     
             // Verifica se campo já está contido no array aModelos
             lExisteCampo := .F.

             For nLaco = 1 to Len(aModelos)

                 If Alltrim(aModelos[nLaco,01]) == Alltrim(aHead[ix])

                    If nInteiro > aModelos[nLaco,03]
                       aModelos[nLaco,03] := nInteiro
                       aModelos[nLaco,05] := nMascara
                    Endif
                                           
                    If nDecimal > aModelos[nLaco,04]
                       aModelos[nLaco,04] := nDecimal
                       aModelos[nLaco,05] := nMascara
                    Endif

                    lExisteCampo := .T.
                    
                    Exit
                    
                 Endif
                 
             Next nLaco       
                    
             If lExisteCampo == .F.
             
                aAdd( aModelos, { Alltrim(aHead[ix])    ,;
                                  ValType(&cFieldValue) ,;
                                  nInteiro              ,;
                                  nDecimal              ,;
                                  nMascara } )

             Endif

             aAdd( aTipoCarac, { aHead[ix], ValType(&cFieldValue), nInteiro, nDecimal, nMascara } )      

	  	 Next

		 Aadd(aData,aFields)
		 Aadd(aTipoField,aTipoCarac)

		 TMP_QRY->(DbSkip())

         If _TipoExecuta == 0
    		oMtrQuery:Set(nContTot++)
    	 Endif	

	  EndDo

	  TMP_QRY->(DbCloseArea())

      If _TipoExecuta == 0
         oTGridResult:= GridTools():New(oGrpResult, aData, aHead, 165,180, 450,100)
      Endif   

      If _TipoExecuta == 0
 	     oMtrQuery:Set(nContTot++)
	     oMtrQuery:lVisibleControl := .F.
	     oMtrQuery:lActive := .F.
	  Endif
  
      // ##################################################################
      // Envia para a função que gerada dados para emissão de relatórios ##
      // ##################################################################
      GERADEFAULT(9)

   EndIf

Return()

Static Function StringType(cValue)

	Local cStrRet := ""

	If (ValType(cValue) == "N")
		cStrRet := cValToChar(cValue)
	ElseIf (ValType(cValue) == "D")
		cStrRet := DtoS(cValue)
	ElseIf (ValType(cValue) == "C")
		cStrRet := cValue
	EndIf

Return(cStrRet)

// ##################################################
// Função que abre a tela de cadastro de perguntas ##
// ##################################################
Static Function ABRPerguntas()

   If Empty(Alltrim(kGrupo))
      GRGrupo()
   Else
      GeraPerguntas()      
   Endif
      
Return(.T.)


// ##################################################
// Função que abre a tela de cadastro de perguntas ##
// ##################################################
Static Function GRGrupo()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cGrPerguntas := Space(10)
   Private oGet1

   Private oDlgAP

   DEFINE MSDIALOG oDlgAP TITLE "Novo Formulário" FROM C(178),C(181) TO C(346),C(437) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(114),C(026) PIXEL NOBORDER OF oDlgAP

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(121),C(001) PIXEL OF oDlgAP
   @ C(060),C(003) GET oMemo2 Var cMemo2 MEMO Size C(121),C(001) PIXEL OF oDlgAP

   @ C(037),C(005) Say "Informe o nome do grupo de pergunta a ser criado" Size C(121),C(008) COLOR CLR_BLACK PIXEL OF oDlgAP

   @ C(047),C(005) MsGet oGet1 Var cGrPerguntas Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAP 

   @ C(066),C(026) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgAP ACTION( CnsPerguntas() )
   @ C(066),C(065) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgAP ACTION( oDlgAP:End() )

   ACTIVATE MSDIALOG oDlgAP CENTERED 

Return(.T.)

// #####################################################
// Função que consiste o grupo de perguntas informado ##
// #####################################################
Static Function CnsPerguntas()

   // Verifica se o grupo de perguntas foi informado
   If Empty(Alltrim(cGrPerguntas))
      MsgStop("Nome do grupo de perguntas não informado. Verifique!")
      Return(.T.)
   Endif
      
   // Verifica se o grupo de perguntas informado já está cadastrado
   dbSelectArea("SX1")
   If dbSeek(cGrPerguntas)
      MsgStop("Grupo de perguntas informado já cadastrado. Verifique!")
      Return(.T.)
   Endif

   kGrupo := cGrPerguntas
   
   oDlgAP:End()

   GeraPerguntas()         

Return(.T.)

// ####################################################
// Função que gera as perguntas para o select criado ##
// ####################################################
Static Function GeraPerguntas()

   Local lFechaG := .F.
   Local cMemo1	 := ""
   Local xGrupo  := kGrupo

   Local oMemo1
   Local oGet1
    
   Private cGrupo  := Alltrim(kGrupo)

   Private aPerguntas := {}

   Private oDlgX

   // Envia para a função que carrega as perguntas
   Carregaperg(0)

   // Desenha a tela para visualização das Perguntas
   DEFINE MSDIALOG oDlgX TITLE "Perguntas - Gerar Excel" FROM C(178),C(181) TO C(467),C(590) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(150),C(026) PIXEL NOBORDER OF oDlgX

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(198),C(001) PIXEL OF oDlgX

   @ C(036),C(005) Say "Perguntas de filtro para o select selecionado" Size C(107),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(010),C(162) Say "Grupo"                                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(019),C(162) MsGet oGet1 Var xGrupo Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgX When lFechaG

   @ C(128),C(046) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("I", xGrupo, "") )
   @ C(128),C(085) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("A", xGrupo, aPerguntas[oPerguntas:nAt,02] ))
   @ C(128),C(124) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgX ACTION( ManPerguntas("E", xGrupo, aPerguntas[oPerguntas:nAt,02] ))
   @ C(128),C(163) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( kGrupo := xGrupo, oDlgX:End() )

   // Desenha o aBrowse na tela
   oPerguntas := TCBrowse():New( 055 , 005, 250, 100,,{"Grupo", "Ordem", "Pergunta"}, {20,50,50,50},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   oPerguntas:SetArray(aPerguntas) 
   oPerguntas:bLine := {||{ aPerguntas[oPerguntas:nAt,01], aPerguntas[oPerguntas:nAt,02], aPerguntas[oPerguntas:nAt,03]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que carrega o grid de perguntas para o grupo selecionado
Static Function CarregaPerg(_Tipo)

   // Limpa o array para ser carregado novamente
   aPerguntas := {}

   // Pesquisa as perguntas
   dbSelectArea("SX1")
   If dbSeek(cGrupo)
      While Alltrim(SX1->X1_GRUPO) == Alltrim(cGrupo) .AND. !SX1->(EOF())
        aAdd( aPerguntas, { Alltrim(SX1->X1_GRUPO), SX1->X1_ORDEM, SX1->X1_PERGUNT } )
        SX1->(dbSkip())
      EndDo
   Else
      aAdd( aPerguntas, { "", "", "" } )
   Endif

   If Len(aPerguntas) == 0
      aAdd( aPerguntas, { "", "", "" } )
   Endif

   If _Tipo == 0
      Return(.T.)
   Endif

   oPerguntas:SetArray(aPerguntas) 
   oPerguntas:bLine := {||{ aPerguntas[oPerguntas:nAt,01], aPerguntas[oPerguntas:nAt,02], aPerguntas[oPerguntas:nAt,03]}}

Return(.T.)

// Função que gera as perguntas para o select criado
Static Function ManPerguntas(_xOperacao, _xGrupo, _xOrdem)

   Local lChumba := .F.
   Local lGrupo  := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cGrupo	  := Space(10)
   Private cOrdem	  := Space(02)
   Private cPortugues := Space(30)
   Private cEspanhol  := Space(30)
   Private cIngles 	  := Space(30)
   Private aTipoCampo := {"S - Selecione o Tipo", "C - Caracter", "N - Numérico", "D - Data"}
   Private cTamanho   := 0
   Private cDecimal   := 0
   Private cRetorno	  := Space(15)
   Private cPesquisa  := Space(06)
   Private cVariavel  := Space(06)
   Private cGSC  	  := "G"

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet8
   Private oGet10
   Private cTipoCampo
      
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgP

   If _xOperacao == "I"
      cGrupo  := _xGrupo
      lGrupo  := .F.
      lChumba := .T.

      // Verifica se foi informado o nome do grupo de perguntas
      If Empty(Alltrim(_xGrupo))
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nome do grupo de perguntas não informado." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif

      // Verifica se o grupo informado já foi utilizado
      If Len(aPerguntas) == 0
         dbSelectArea("SX1")
         DbSetOrder(1)
         If dbSeek(_xGrupo + Space(10 - Len(_xGrupo)) + _xOrdem)
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Grupo de pergunta já utilizado." + chr(13) + chr(10) + "Verifique!")
            Return(.T.)
         Endif
      Endif   

   Else
      lGrupo  := .F.
      lChumba := .F.
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(_xGrupo + Space(10 - Len(_xGrupo)) + _xOrdem)
         cGrupo	    := SX1->X1_GRUPO
         cOrdem	    := SX1->X1_ORDEM
         cPortugues := SX1->X1_PERGUNT
         cEspanhol  := SX1->X1_PERSPA
         cIngles 	:= SX1->X1_PERENG
         cVariavel  := SX1->X1_VARIAVL

         Do Case
            Case SX1->X1_TIPO == "C"
                 cTipoCampo := "C - Caracter"
            Case SX1->X1_TIPO == "N"
                 cTipoCampo := "N - Numérico"
            Case SX1->X1_TIPO == "D"
                 cTipoCampo := "D - Data"
            Otherwise
                 cTipoCampo := "S - Selecione o Tipo"                      
         EndCase                 

         cTamanho   := SX1->X1_TAMANHO
         cDecimal   := SX1->X1_DECIMAL
         cGSC  	    := SX1->X1_GSC
         cRetorno	:= SX1->X1_VAR01
         cPesquisa  := SX1->X1_F3
      Else
         cGrupo	    := _xGrupo
         cOrdem	    := Space(02)
         cPortugues := Space(30)
         cEspanhol  := Space(30)
         cIngles 	:= Space(30)
         cVariavel  := Space(06)
         cTipoCampo := "S - Selecione o Tipo"                      
         cTamanho   := 0
         cDecimal   := 0
         cGSC  	    := "G"
         cRetorno	:= Space(15)
         cPesquisa  := Space(06)
      Endif
   Endif

   // Desenha a tela para visualização dos campos
   DEFINE MSDIALOG oDlgP TITLE "Perguntas" FROM C(178),C(181) TO C(481),C(627) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(110),C(026) PIXEL NOBORDER OF oDlgP

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(214),C(001) PIXEL OF oDlgP
   @ C(129),C(003) GET oMemo2 Var cMemo2 MEMO Size C(214),C(001) PIXEL OF oDlgP
   
   @ C(038),C(005) Say "Grupo"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(038),C(047) Say "Ordem"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(059),C(005) Say "Pergunta em Português" Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(059),C(142) Say "Tipo"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(082),C(005) Say "Pergunta em Espanhol"  Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(082),C(142) Say "Tamanho"               Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(082),C(195) Say "Decimal"               Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(104),C(005) Say "Pergunta em Inglês"    Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(104),C(142) Say "Var. Retorno"          Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(104),C(195) Say "F3"                    Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
															  
   @ C(047),C(005) MsGet    oGet1  Var       cGrupo     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lGrupo
   @ C(047),C(047) MsGet    oGet2  Var       cOrdem     Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(069),C(005) MsGet    oGet3  Var       cPortugues Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(091),C(005) MsGet    oGet8  Var       cEspanhol  Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(114),C(005) MsGet    oGet10 Var       cIngles    Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP

   @ C(069),C(142) ComboBox cTipoCampo Items aTipoCampo Size C(071),C(010)                              PIXEL OF oDlgP

   @ C(091),C(142) MsGet    oGet4  Var       cTamanho   Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgP
   @ C(091),C(195) MsGet    oGet5  Var       cDecimal   Size C(018),C(009) COLOR CLR_BLACK Picture "@E 99"  PIXEL OF oDlgP
   @ C(114),C(142) MsGet    oGet6  Var       cRetorno   Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP
   @ C(114),C(195) MsGet    oGet7  Var       cPesquisa  Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP

   @ C(135),C(071) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgP ACTION(GravaPrg(_xOperacao))
   @ C(135),C(110) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION(oDlgP:End())

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)

// Função que grava a pergunta
Static Function GravaPrg(_xOperacao)

   If Empty(Alltrim(cOrdem))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O campo Ordem não foi informado.")
      Return(.T.)
   Endif      

   If Substr(cTipoCampo,01,01) == "S"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O Tipo de Campo não foi selecionado.")
      Return(.T.)
   Endif      

   // Inclusão
   If _xOperacao == "I"
  	  PutSx1( cGrupo, cOrdem,cPortugues, cEspanhol, cIngles, cVariavel, Substr(cTipoCampo,01,01), cTamanho, cDecimal,0, cGSC,"", cPesquisa,"","", cRetorno," ","","","","","","","","","","","","","","","")
   Endif

   // Aletração
   If _xOperacao == "A"
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(cGrupo + Space(10 - Len(cGrupo)) + cOrdem)
         RecLock("SX1",.F.)
         SX1->X1_PERGUNT := cPortugues
         SX1->X1_PERSPA  := cEspanhol 
         SX1->X1_PERENG  := cIngles 
         SX1->X1_VARIAVL := "MV_CH" + Strzero(Int(Val(cOrdem)),02)
         SX1->X1_TIPO    := Substr(cTipoCampo,01,01)
         SX1->X1_TAMANHO := cTamanho 
         SX1->X1_DECIMAL := cDecimal 
         SX1->X1_GSC     := cGSC  	 
         SX1->X1_VAR01   := cRetorno
         SX1->X1_F3      := cPesquisa
         MsUnLock()              
      Endif
   Endif
   
   // Exclusão
   If _xOperacao == "E"
      dbSelectArea("SX1")
      DbSetOrder(1)
      If dbSeek(cGrupo + Space(10 - Len(cGrupo)) + cOrdem)
         RecLock("SX1",.F.)
         DbDelete()
         MsUnLock()              
      Endif
   Endif

   oDlgP:End()

   CarregaPerg(1)
   
Return(.T.)

// Função que habilita a indicação dos usuários que possuiram acesso a consulta
Static Function PermiteAcesso()

   MsgRun("Favor Aguarde! Carregando lista de usuários ...", "Pesquisa de Usuários",{|| AcessoUsuario() })

Return(.T.)

// Função que habilita a indicação dos usuários que possuiram acesso a consulta
Static Function AcessoUsuario()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgA

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private aUsuarios := {}
   Private oUsuarios

   // Carrega informações dos usuários para listagem
   For ncontar := 1 to 1200

       cId := StrZero(nContar,6)

       PswOrder(1)

       If PswSeek(cId,.T.)

          aReturn := PswRet()

          aAdd( aUsuarios, { .F.            ,;
                             aReturn[1][1]  ,;  // 01 - Código do Usuário
                             aReturn[1][4]})    // 02 - Nome completo do usuário
       Endif

   Next nContar

   If Len(aUsuarios) == 0
      aAdd( aUsuarios, {.F., "", ""})
   Endif

   // Marca os já marcados   
   For nContar = 1 to Len(aUsuarios)
       For nLocaliza = 1 to Len(aParametros)
           If aParametros[nLocaliza,01] == "[A]"
              If Alltrim(aParametros[nLocaliza,03]) == Alltrim(aUsuarios[nContar,02])
                 aUsuarios[nContar,01] := .T.
                 Exit
              Endif
           Endif
       Next nLocaliza
   Next nContar                         

   // Ordena o Array pelo campo Ordem
   ASORT(aUsuarios,,,{ | x,y | x[3] < y[3] } )

   // Desenha a tela
   DEFINE MSDIALOG oDlgA TITLE "Permissão de acesso a consultas" FROM C(178),C(181) TO C(559),C(511) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(150),C(026) PIXEL NOBORDER OF oDlgA

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(157),C(001) PIXEL OF oDlgA

   @ C(036),C(005) Say "Selecione os usuários para acesso" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(174),C(122) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgA ACTION( FechaoDlgA() )

   // Cria o list dos usuários para marcar/desmarcar
   @ 058,005 LISTBOX oUsuarios FIELDS HEADER "", "Código", "Nome dos Usuários" PIXEL SIZE 200,160 OF oDlgA ;
                               ON dblClick(aUsuarios[oUsuarios:nAt,1] := !aUsuarios[oUsuarios:nAt,1],oUsuarios:Refresh())     
   oUsuarios:SetArray( aUsuarios )
   oUsuarios:bLine := {||     {Iif(aUsuarios[oUsuarios:nAt,01],oOk,oNo),;
             		    		   aUsuarios[oUsuarios:nAt,02],;
         	         	           aUsuarios[oUsuarios:nAt,03]}}

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Função que carrega o campo habilita a indicação dos usuários que possuiram acesso a consulta
Static Function FechaoDlgA()

   Local nContar     := 0
   Local cGravar     := ""
   Local lTemUsuario := .F.
   Local aTemporaria := {}

   cUsuarios := ""

   lTemusuario := .F.
                                          
   // ##############################################
   // Eliimina o parâmetro [A] para nova gravação ##
   // ##############################################        
   For nContar = 1 to Len(aParametros)
      
       If aParametros[nContar,01] == "[A]"
          Loop
       Endif

       If aParametros[nContar,01] == "[00]"
          Loop
       Endif

       If aParametros[nContar,01] == "[00"
          Loop
       Endif

       aAdd( aTemporaria, { aParametros[nContar,01],;
                            aParametros[nContar,02],;
                            aParametros[nContar,03]})
                            
   Next nContar                            

   // #############################
   // Recria o array aParametros ##
   // #############################
   aParametros := {}
   For nContar = 1 to Len(aTemporaria)
       aAdd( aparametros, { aTemporaria[nContar,01],;
                            aTemporaria[nContar,02],;
                            aTemporaria[nContar,03]})
                                              
   Next nContar                            
  
   // Grava os parâmetros de acesso no array aParametros   
   For nContar = 1 to Len(aUsuarios)
       If aUsuarios[nContar,01] == .T.
          // Envia para a função que grava o array aparamentros
          GravaParametros("[A]", nContar, aUsuarios[nContar,02])
          lTemUsuario := .T.
          cGravar     := cGravar + aUsuarios[nContar,02] + "|"
       Endif
   Next nContar

   If lTemUsuario == .T.
      cUsuarios := cGravar
   Else
      cUsuarios := ""
   Endif   
           
   oDlgA:End() 
   
Return(.T.)

// Função que expande a consulta ou resultado para melhor visualização
Static Function Expande(_Qual)

   // 1 == Consulta
   // 2 - Resultado

   Local cMemo2  := ""
   Local oMemo2
   Local nContar := 0

   Private aDataPes   := {}
   Private cStringPes := "Filtro(s) Utilizado(s): " + chr(13) + chr(10) + chr(13) + chr(10)

   Private aCamposExp := {}
   Private aOperacoes := {"Selecione Operação", "Igual a", "Diferente de", "Menor que", "Menor ou igual a", "Maior que", "Maior ou Igual a", "Contém a expressão", "Não contém a expressão" }
   Private aOrdenaExp := {}
   Private cCamposExp
   Private cOperacoes
   Private cOrdenaExp

   Private cExpressao := Space(254)
   Private cGet1

   // Guarda o resultado original
   For nContar = 1 to Len(aData)
       aAdd( aDataPes, aData[nContar])
   Next nContar    

   // Carrega o combo dos campos para seleção da pesquisa
   aAdd( aCamposExp, "Selecione Campo" )
   aAdd( aOrdenaExp, "Selecione Campo" )

   For nContar = 1 to Len(aHead)
       aAdd( aCamposExp, aHead[nContar] )
       aAdd( aOrdenaExp, aHead[nContar] )       
   Next nContar    

   Private oDlgE

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgE TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(634),C(1170) PIXEL

   @ C(005),C(003) Jpeg FILE "advpltools.png" Size C(098),C(022) PIXEL NOBORDER OF oDlgE

   @ C(028),C(003) GET oMemo2 Var cMemo2 MEMO Size C(488),C(001) PIXEL OF oDlgE

   If _Qual == 1

      // Expande o Grid
      oTMuGetQry := tMultiget():New( 040, 003, {| u | if( pCount() > 0, cTQry := u, cTQry ) },oGrpQuery, 627, 227,oTFontCNEW ,,,,, .T. )
      oTMuGetQry:EnableVScroll(.T.)
   Else
      
      @ C(034),C(005) Say "Campos"      Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
      @ C(034),C(085) Say "Operadores"  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
      @ C(034),C(170) Say "Expressão"   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
      @ C(034),C(425) Say "Ordenar por" Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

      @ C(043),C(005) ComboBox cCamposExp Items aCamposExp Size C(075),C(010) PIXEL OF oDlgE
      @ C(043),C(085) ComboBox cOperacoes Items aOperacoes Size C(080),C(010) PIXEL OF oDlgE
      @ C(043),C(425) ComboBox cOrdenaExp Items aOrdenaExp Size C(065),C(010) PIXEL OF oDlgE ON CHANGE OrdenaPes()

      @ C(043),C(170) MsGet    oGet1     Var   cExpressao Size C(169),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

      @ C(041),C(344) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlgE ACTION( PsqExpressao() )
	  @ C(041),C(382) Button "Limpar Filtro" Size C(037),C(012) PIXEL OF oDlgE ACTION( LimpaExpande() )
	
      // Grid de resultados
      oTGridResult:= GridTools():New(oGrpResult, aDataPes, aHead, 075,003, 627,190)

      @ C(212),C(003) Button "Filtros"    Size C(048),C(012) PIXEL OF oDlgE ACTION( MsgAlert(cStringPes) )

   Endif      

   @ C(212),C(445) Button "Voltar"     Size C(048),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)              

// #####################################
// Função que ordena o grid expandido ##
// #####################################
Static Function Ordenapes()

   Local nConbtar      := 0
   Local nPosicaoCampo := 0

   If Alltrim(Upper(cOrdenaExp)) == "SELECIONE CAMPO"
      Return(.T.)
   Endif

   // Localiza a posição do campo selecionado no array aHead
   nPosicaoCampo := 0
   For nContar = 1 to Len(aHead)
       If Alltrim(Upper(aHead[nContar])) == Alltrim(Upper(cOrdenaExp))
          nPosicaoCampo := nContar
          Exit
       Endif
   Next nContar            

   // Ordena o Array pelo campo Ordem
   ASORT(aDataPes,,,{ | x,y | x[nPosicaoCampo] < y[nPosicaoCampo] } )

   // Refresh do grid   
   oTGridResult:= GridTools():New(oGrpResult, aDataPes, aHead, 075,003, 627,190)   

Return(.T.)

// ###############################################################
// Função que pesquisa a expressão na tela de expandir consulta ##
// ###############################################################
Static Function PsqExpressao()

   Local nContar       := 0
   Local nPosicaoCampo := 0
   Local aDataFil      := {}

   If Alltrim(Upper(cCamposExp)) == "SELECIONE CAMPO"
      MsgAlert("Campo a ser utilizado para pesquisa não selecionado. Verifique!")
      Return(.T.)
   Endif
   
   If Alltrim(Upper(cOperacoes)) == "SELECIONE OPERAÇÃO"
      MsgAlert("Operação a ser utilizada não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(cExpressao))
      MsgAlert("Expressão a ser pesquisada não informada. Verifique!")
      Return(.T.)
   Endif

   cStringpes := cStringPes + Alltrim(Upper(cCamposExp)) + " " + Alltrim(Upper(cOperacoes)) + " " + Alltrim(cExpressao) + chr(13) + chr(10)

   // Localiza a posição do campo selecionado no array aHead
   nPosicaoCampo := 0
   For nContar = 1 to Len(aHead)
       If Alltrim(Upper(aHead[nContar])) == Alltrim(Upper(cCamposExp))
          nPosicaoCampo := nContar
          Exit
       Endif
   Next nContar            
   
   // Pesquisa e carrega o array aDataFil com os dados filrados
   For nContar = 1 to Len(aDataPes)
   
       Do Case
          Case cOperacoes == "Igual a"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) == Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Diferente de"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) <> Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Menor que"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) < Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Menor ou igual a"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) <= Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Maior que"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) > Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Maior ou Igual a"
               If Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])) >= Alltrim(Upper(cExpressao))          
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Contém a expressão"
               If U_P_OCCURS(Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])), Alltrim(Upper(cExpressao)), 1) <> 0
                  aAdd( aDataFil, aDataPes[nContar])
               Endif

          Case cOperacoes == "Não contém a expressão"
               If U_P_OCCURS(Alltrim(Upper(aDataPes[nContar,nPosicaoCampo])), Alltrim(Upper(cExpressao)), 1) == 0
                  aAdd( aDataFil, aDataPes[nContar])
               Endif
       EndCase

   Next nContar    

   aDatapes := {}

   // Carrega resultado para display
   For nContar = 1 to Len(aDataFil)
       aAdd( aDataPes, aDataFil[nContar])
   Next nContar    

   // Refresh do grid   
   oTGridResult:= GridTools():New(oGrpResult, aDataPes, aHead, 075,003, 627,190)   

Return(.T.)      

// #############################################################
// Função que restaura a consulta original na tela de expnsão ##
// #############################################################
Static Function LimpaExpande()

   Local nContar  := 0

   cStringPes := "Filtro(s) Utilizado(s): " + chr(13) + chr(10) + chr(13) + chr(10)

   cCamposExp := "Selecione Campo" 
   cOperacoes := "Selecione Operação"
   cExpressao := Space(254)

   oGet1:Refresh()

   aDataPes := {}
   
   For nContar = 1 to Len(aData)
       aAdd( aDatapes, aData[nContar])
   Next nContar    
   
   // Refresh do grid   
   oTGridResult:= GridTools():New(oGrpResult, aDataPes, aHead, 075,003, 627,190)   
   
Return(.T.)

// ################################################
// Função que gera a saída em Excel do resultado ##
// ################################################
Static Function kGeraexcel(_TipoChamada)

   Local cSql        := ""
   Local nContar     := 0
   Local lVazio      := .F.
   Local aItensExcel := {}
   Local aCampos     := {}
   Local aVerifica   := {}

   Private aCabExcel := {}
   
   // Verifica se o equipamento possui o execl instalado 
   If !ApOleClient("MSExcel")
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
      Return(.T.)
   EndIf

   // Consiste o título da quary
   If Empty(Alltrim(cPesquisa))
      MsgAlert("Título da query deve ser informada.")
      Return(.T.)
   Endif
   
   // Consiste a informação do módulo
   If Substr(cComboBx2,01,02) == "00"
      MsgAlert("Módulo não selecionado.")
      Return(.T.)
   Endif

   If Len(aData) == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + " Nenhum resultado de consulta disponível para visualização em Excel.")
      Return(.T.)
   Endif

   // Crarega o array aCampos
   aCabExcel := {}

   For nContar = 1 to Len(aHead)

       x_Campo   := aHead[nContar]
       x_Tipo    := "C"
       x_Tamanho := 10
       x_Decimal := 0
       x_Mascara := "@!"
       x_Titulo  := aHead[nContar]

       AAdd(aCabExcel, {Trim(x_Titulo) ,;
                        x_Campo        ,;
                        x_Mascara      ,;
                        x_Tamanho      ,;
                        x_Decimal      ,;
                        x_Tipo         ,;
                        "1"            ,;
                        ""             ,;
                        ""             ,;
                        ""             })

   Next nContar
      
   // Gera o Excel do resultado   aHeader, aCols
   MsgRun("Favor Aguarde! Exportando os registros para o Excel ...", "Exportando os Registros para o Excel",{||DlgToExcel({{"GETDADOS",kTitulo,aCabExcel,aData}})})
   
Return

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function GeraTXT(_TipoChamada)

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cString   := ""
   Local nContar   := ""
   Local lPrimeiro := .T.
   Local lVolta    := .T.
   Local oMemo1

   Private cOriCaminho  := Space(250) 
   Private lSeparador   := .F.
   Private aTipoArquivo	:= {"00 - SELECIONE O TIPO DE ARQUIVO", "01 - TXT TABULADO", "02 - TXT SEM TABULAÇÃO", "03 - TXT COM SEPARADOR", "04 - CSV SEM TABULAÇÂO", "05 - CSV COM SEPARADOR" }
   Private cComboBx1
   Private cGeraTXT     := Space(250)
   Private cSeparador   := Space(001)
   Private lFiltrosPar  := .T.
   Private lCabecalho   := .T.
   Private oCheckBox1
   Private oCheckBox2
   Private oGet1
   Private oGet2

   Private oDlgTXT
   
   // Só verifica se chamado pelo ADMIN
   If _TipoChamada == 0
      // Consiste o título da quary
      If Empty(Alltrim(cPesquisa))
         MsgAlert("Título da consulta não informado.")
         Return(.T.)
      Endif
   
      // Consiste a informação do módulo
      If Substr(cComboBx2,01,02) == "00"
         MsgAlert("Módulo não selecionado.")
         Return(.T.)
      Endif
   Endif   

   If Len(aData) == 0
      MsgStop("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + " Nenhum resultado de consulta disponível para geração de arquivo TXT.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgTXT TITLE "Novo Formulário" FROM C(178),C(181) TO C(388),C(792) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(126),C(026) PIXEL NOBORDER OF oDlgTXT

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(297),C(001) PIXEL OF oDlgTXT

   @ C(036),C(005) Say "Tipo de Arquivo a ser gerado"          Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT
   @ C(036),C(141) Say "Separdor"                              Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT
   @ C(062),C(005) Say "Caminho onde arquivo deverá ser salvo" Size C(096),C(008) COLOR CLR_BLACK PIXEL OF oDlgTXT

   @ C(046),C(005) ComboBox cComboBx1  Items aTipoArquivo Size C(131),C(010)                              PIXEL OF oDlgTXT ON CHANGE AbreSeparador()
   @ C(046),C(141) MsGet    oGet2      Var   cSeparador   Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT When lSeparador
   @ C(041),C(172) CheckBox oCheckBox2 Var   lFiltrosPar  Prompt "Gerar arquivo com parâmertos de filtro" Size C(102),C(008) PIXEL OF oDlgTXT
   @ C(054),C(172) CheckBox oCheckBox1 Var   lCabecalho   Prompt "Gerar arquivo com cabeçalho dos campos" Size C(111),C(008) PIXEL OF oDlgTXT
   @ C(072),C(005) MsGet    oGet1      Var   cGeraTXT     Size C(278),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTXT When lChumba
   @ C(072),C(287) Button "..."                           Size C(012),C(009)                              PIXEL OF oDlgTXT ACTION( CaminhoTXT())

   @ C(088),C(113) Button "Gerar"  Size C(037),C(012) PIXEL OF oDlgTXT ACTION( xGeraTXT() )
   @ C(088),C(151) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgTXT ACTION( oDlgTXT:End() )

   ACTIVATE MSDIALOG oDlgTXT CENTERED 

Return(.T.)

// #######################################################
// Função que abre ou fecha o campo Separador de campos ##
// #######################################################
Static Function AbreSeparador()

   Do Case
      Case Substr(cComboBx1,01,02) == "00"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "01"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "02"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "03"
           cSeparador := Space(001)
           lSeparador := .T.
      Case Substr(cComboBx1,01,02) == "04"
           cSeparador := Space(001)
           lSeparador := .F.
      Case Substr(cComboBx1,01,02) == "05"                        
           cSeparador := ";"
           lSeparador := .T.
   EndCase

   oGet2:Refresh()

   If Empty(Alltrim(cOriCaminho))
   Else

      cGeraTXT := Space(250)

      Do Case
         // 01 - TABULADO
         Case Substr(cComboBx1,01,02) == "01"
              cGeraTXT := Alltrim(cOriCaminho) + Alltrim(cPesquisa) + ".TXT"

         // 02 - TXT SEM TABULAÇÃO
         Case Substr(cComboBx1,01,02) == "02"
              cGeraTXT := Alltrim(cOriCaminho) + Alltrim(cPesquisa) + ".TXT"

         // 03 - TXT COM SEPARADOR
         Case Substr(cComboBx1,01,02) == "03"
              cGeraTXT := Alltrim(cOriCaminho) + Alltrim(cPesquisa) + ".TXT"

         // 04 - CSV SEM TABULAÇÂO
         Case Substr(cComboBx1,01,02) == "04"
              cGeraTXT := Alltrim(cOriCaminho) + Alltrim(cPesquisa) + ".CSV"
        
         // 05 - CSV COM SEPARADOR
         Case Substr(cComboBx1,01,02) == "05"
              cGeraTXT := Alltrim(cOriCaminho) + Alltrim(cPesquisa) + ".CSV"

      EndCase

      oGet1:Refresh()
      
   Endif   

Return(.T.)   

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function xGeraTXT()

   If Substr(cComboBx1,01,02) == "00"
      MsgStop("Tipo de arquivo a ser gerado não selecionado.")
      Return(.T.)
   Endif

   Do Case
      Case Substr(cComboBx1,01,02) == "03"
           If Empty(Alltrim(cSeparador))
              MsgStop("Separador de campos para o tipo de arquivo selecionado não informado.")
              Return(.T.)
           Endif
      Case Substr(cComboBx1,01,02) == "05"
           If Empty(Alltrim(cSeparador))
              MsgStop("Separador de campos para o tipo de arquivo selecionado não informado.")
              Return(.T.)
           Endif
   EndCase

   If Empty(Alltrim(cGeraTXT))
      MsgStop("Caminho e Nome do arquivo a ser salvo não informado.")
      Return(.T.)
   Endif

   If File(Alltrim(cGeraTXT))
      If (MsgYesNo("Arquivo já existe na pasta infromada. Deseja sobrescrever o arquivo?","Atenção!"))
      Else
         Return(.T.)
      Endif
   Endif      
                                                                              
   // Envia para a função que gera o arquivo conforme parâmetros informados
   MsgRun("Aguarde! Preparando inclusão de consulta ...", "Manutenção de Consulta",{|| yGeraTXT() })

Return(.T.)

// #########################################
// Função que gera a saída em Arquivo TXT ##
// #########################################
Static Function yGeraTXT()

   Local cString   := ""
   Local nContar   := ""
   Local lPrimeiro := .T.

   // Somente incluirá os filtros se solicitado
   If lFiltrosPar == .T.
      cString   := Strtran(kTitulo, "?", ":") + chr(13) + chr(10) + chr(13) + chr(10)
   Endif   

   // Inicializa os contadores de espaços
   For nContar = 1 to Len(aHead[1])
       j := Strzero(nContar,2)
       nEspaco&j := 0
   Next nContar    

   // Imprime os dados no arquivo
   For nContar = 1 to Len(aData)

       // Inclui o cabeçalho 
       If lPrimeiro == .T.

          For nCabecalho = 1 to Len(aHead)
              j := Strzero(nCabecalho,2)
              If lCabecalho == .T.
                 cString   += aHead[nCabecalho] + " " 

                 Do Case
                    // 01 - TABULADO
                    Case Substr(cComboBx1,01,02) == "01"
                         cString += aHead[nCabecalho] + " " 

                    // 02 - TXT SEM TABULAÇÃO
                    Case Substr(cComboBx1,01,02) == "02"
                         cString += Alltrim(aHead[nCabecalho]) + "" 

                    // 03 - TXT COM SEPARADOR
                    Case Substr(cComboBx1,01,02) == "03"
                         cString += Alltrim(aHead[nCabecalho]) + Alltrim(cSeparador)

                    // 04 - CSV SEM TABULAÇÂO
                    Case Substr(cComboBx1,01,02) == "04"
                         cString += aHead[nCabecalho] + ""
        
                    // 05 - CSV COM SEPARADOR
                    Case Substr(cComboBx1,01,02) == "05"
                         cString += aHead[nCabecalho] + Alltrim(cSeparador)
                 EndCase

//               nEspaco&j := Len(aHead[nCabecalho])
              Endif
          Next nCabecalho                      
          
          If lCabecalho == .T.
             cString += chr(13) + chr(10)
          Endif   
          
          lPrimeiro := .F.
       Endif

       For nCaptura = 1 to Len(aData[1])        
           j := Strzero(nCaptura,2)
//         cString += aData[nContar,nCaptura] + Space(nEspaco&j)

           Do Case
              // 01 - TABULADO
              Case Substr(cComboBx1,01,02) == "01"
                   cString += aData[nContar,nCaptura] + " "

              // 02 - TXT SEM TABULAÇÃO
              Case Substr(cComboBx1,01,02) == "02"
                   cString += Alltrim(aData[nContar,nCaptura]) + ""

              // 03 - TXT COM SEPARADOR
              Case Substr(cComboBx1,01,02) == "03"
                   cString += Alltrim(aData[nContar,nCaptura]) + Alltrim(cSeparador)

              // 04 - CSV SEM TABULAÇÂO
              Case Substr(cComboBx1,01,02) == "04"
                   cString += aData[nContar,nCaptura] + ""
        
              // 05 - CSV COM SEPARADOR
              Case Substr(cComboBx1,01,02) == "05"
                   cString += aData[nContar,nCaptura] + Alltrim(cSeparador)
           EndCase

       Next nCaptura    

       cString += chr(13) + chr(10)

   Next nContar

   // Gera o arquivo conforme parâametros
   nHdl := fCreate(cGeraTXT)

   If nHdl == -1
      MsgaStop("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Erro ao gravar arquivo TXT." + chr(13) + chr(10) + "Verifique se a pasta informada está correta.")
      Return(.T.)
   Endif

   fWrite (nHdl, cString ) 
   fClose(nHdl)

   MsgAlert("Arquivo " + Alltrim(cGeraTXT) + " gerado com sucesso.")
   
Return(.T.)   

// Função que abre diálogo para seleção do caminho de gravação do arquvo TXT
Static Function CaminhoTXT()

   cGeraTXT := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )

   cOriCaminho := Alltrim(cGeraTXT)

   Do Case
      // 01 - TABULADO
      Case Substr(cComboBx1,01,02) == "01"
           cGeraTXT := Alltrim(cGeraTXT) + Alltrim(cPesquisa) + ".TXT"

      // 02 - TXT SEM TABULAÇÃO
      Case Substr(cComboBx1,01,02) == "02"
           cGeraTXT := Alltrim(cGeraTXT) + Alltrim(cPesquisa) + ".TXT"

      // 03 - TXT COM SEPARADOR
      Case Substr(cComboBx1,01,02) == "03"
           cGeraTXT := Alltrim(cGeraTXT) + Alltrim(cPesquisa) + ".TXT"

      // 04 - CSV SEM TABULAÇÂO
      Case Substr(cComboBx1,01,02) == "04"
           cGeraTXT := Alltrim(cGeraTXT) + Alltrim(cPesquisa) + ".CSV"
        
      // 05 - CSV COM SEPARADOR
      Case Substr(cComboBx1,01,02) == "05"
           cGeraTXT := Alltrim(cGeraTXT) + Alltrim(cPesquisa) + ".CSV"

   EndCase

Return .T. 

// ######################################
// Função que abre menu dos relatórios ##
// ######################################
Static Function AbrRelPadraoProtheus(_TipoAbertura)

   Local nContar    := 0
   Local lExistePar := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private kk_Voltar_Rel := 2                                                                                                                                

   // Só consiste se for pelo ADMIN
   If _TipoAbertura == 0
      // Consiste o título da quary
      If Empty(Alltrim(cPesquisa))
         MsgAlert("Título da consulta não informado.")
         Return(.T.)
      Endif
   
      // Consiste a informação do módulo
      If Substr(cComboBx2,01,02) == "00"
         MsgAlert("Módulo não selecionado.")
         Return(.T.)
      Endif
   Endif

   // Verifica se já existe configuração de relatório. Se não existir, envia para o gerador default de relatório
   lExistePar := .F.

   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[P]" .Or. ;
          aParametros[nContar,01] == "[C]" .Or. ;
          aParametros[nContar,01] == "[D]"
          lExistePar := .T.
          Exit
       Endif
   Next nContar
          
   If lExistePar == .F.
      GERADEFAULT(0)
      Return(.T.)
   Endif

   Private oDlgCFG

   If _TipoAbertura == 0

      DEFINE MSDIALOG oDlgCFG TITLE "Configurador de Relatório" FROM C(178),C(181) TO C(420),C(449) PIXEL

      @ C(005),C(006) Jpeg FILE "advpltools.png" Size C(126),C(026) PIXEL NOBORDER OF oDlgCFG

      @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(126),C(001) PIXEL OF oDlgCFG

      @ C(036),C(005) Button "Configurar Logomarca"  Size C(125),C(020) PIXEL OF oDlgCFG ACTION( ConfiguraLog() )
      @ C(057),C(005) Button "Configuação de Campos" Size C(125),C(020) PIXEL OF oDlgCFG ACTION( GERADEFAULT(0) )
      @ C(078),C(005) Button "Emitir Relatório"      Size C(125),C(020) PIXEL OF oDlgCFG ACTION( GeraRelPadrao() )
      @ C(099),C(005) Button "Voltar"                Size C(125),C(020) PIXEL OF oDlgCFG ACTION( oDlgCFG:End() )

      ACTIVATE MSDIALOG oDlgCFG CENTERED 
      
   Else
   
      GERADEFAULT(_TipoAbertura)
   
   Endif   

Return(.T.)

// ###############################################
// Função que gera relatório no padrão Protheus ##
// ###############################################
Static Function RelPadraoProtheus()

   GeraRelPadrao()

Return(.T.)

// ####################################################################
// Função que abre a tela de informação da logomarca para impressão  ##
// ####################################################################
Static Function ConfiguraLog()

   Local lChumba := .F.

   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oMemo2
   Local oMemo3

   Private lLogomarca := .F.
   Private oCheckBox1

   Private cLogomarca := Space(250)
   Private cColuna    := "50   "
   Private cSaltoLin  := "100  "
   Private cLargura   := Space(005)
   Private cAltura    := Space(005)   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5   

   Private oDlgLogo

   // Captura os dados para visualização
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[L]"
          lLogomarca := IIF(   U_P_CORTA(aParametros[nContar,03], "|", 1) == "N", .F., .T.)
          cLogomarca := U_P_CORTA(aParametros[nContar,03], "|", 2)
          cColuna    := U_P_CORTA(aParametros[nContar,03], "|", 3)
          cSaltoLin  := U_P_CORTA(aParametros[nContar,03], "|", 4)
          cLargura   := U_P_CORTA(aParametros[nContar,03], "|", 5)
          cAltura    := U_P_CORTA(aParametros[nContar,03], "|", 6)
    
          If Empty(Alltrim(cColuna))
             cColuna := "50   "
          Endif
             
          If Empty(Alltrim(cSaltoLin))
             cSaltoLin := "100  "
          Endif

          If Empty(Alltrim(cLargura))
             cColuna := "267  "
          Endif
             
          If Empty(Alltrim(cAltura))
             cSaltoLin := "90   "
          Endif

          If Len(Alltrim(cLargura)) < 5                                     
             cLargura := Alltrim(cLargura) + Space(5 - Len(Alltrim(cLargura)))
          Endif
              
          If Len(Alltrim(cAltura)) < 5      
             cAltura := Alltrim(cAltura) + Space(5 - Len(Alltrim(cAltura)))
          Endif
    
          Exit
        Endif
   Next nContar      

   DEFINE MSDIALOG oDlgLogo TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(610),C(734) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(098),C(022) PIXEL NOBORDER OF oDlgLogo

   @ C(028),C(003) GET oMemo2 Var cMemo2 MEMO Size C(269),C(001) PIXEL OF oDlgLogo
   @ C(195),C(003) GET oMemo3 Var cMemo3 MEMO Size C(269),C(001) PIXEL OF oDlgLogo

   @ C(048),C(005) Say "Logomarca a ser utilizada para impressão" Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlgLogo
   @ C(071),C(005) Say "Coluna de Impressão"                      Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgLogo
   @ C(071),C(066) Say "Salto de Linha"                           Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgLogo
   @ C(071),C(118) Say "Largura no Relatório"                     Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgLogo
   @ C(071),C(178) Say "Altura no Relatório"                      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgLogo
   
   @ C(033),C(005) CheckBox oCheckBox1 Var lLogomarca Prompt "Imprimir logomarca" Size C(055),C(008)       PIXEL OF oDlgLogo
   @ C(058),C(005) MsGet    oGet1      Var cLogomarca Size C(254),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgLogo When lChumba
   @ C(058),C(262) Button "..."                       Size C(010),C(009)                                   PIXEL OF oDlgLogo ACTION( CaminhoLog(0) )
   @ C(080),C(005) MsGet    oGet2      Var cColuna    Size C(030),C(009) COLOR CLR_BLACK Picture "@ XXXXX" PIXEL OF oDlgLogo
   @ C(080),C(066) MsGet    oGet3      Var cSaltoLin  Size C(030),C(009) COLOR CLR_BLACK Picture "@ XXXXX" PIXEL OF oDlgLogo
   @ C(080),C(118) MsGet    oGet4      Var cLargura   Size C(030),C(009) COLOR CLR_BLACK Picture "@ XXXXX" PIXEL OF oDlgLogo 
   @ C(080),C(178) MsGet    oGet5      Var cAltura    Size C(030),C(009) COLOR CLR_BLACK Picture "@ XXXXX" PIXEL OF oDlgLogo
// @ C(077),C(223) Button "Ajustar Tamanho"           Size C(050),C(012)                              PIXEL OF oDlgLogo ACTION( CaminhoLog(1) )
   @ C(094),C(005) Jpeg FILE cLogomarca Size C(Int(Val(cLargura))),C(Int(Val(cAltura))) PIXEL NOBORDER OF oDlgLogo

   @ C(200),C(089) Button "Salvar" Size C(048),C(012) PIXEL OF oDlgLogo ACTION( SairLogomarca() )
   @ C(200),C(139) Button "Voltar" Size C(048),C(012) PIXEL OF oDlgLogo ACTION( oDlgLogo:End() )

   ACTIVATE MSDIALOG oDlgLogo CENTERED 

Return(.T.)

// Função que abre diálogo para seleção da logomarca a ser inpressa no relatório
Static Function CaminhoLog(_Tipo)

//   If _Tipo == 0
      cLogomarca := cGetFile('*.*', "Selecione o arquivo de logomarca a ser utilizado para impressão.",1,"C:\",.F.,16,.F.)
//   Else
      
      If Int(val(cLargura)) == 0
         cLargura := "267"
      Endif   
   
      If Int(val(cAltura)) == 0
         cAltura := "90"
      Endif   

//   Endif      

   @ C(094),C(005) Jpeg FILE cLogomarca Size C(Int(Val(cLargura))),C(Int(Val(cAltura))) PIXEL NOBORDER OF oDlgLogo
   oDlgLogo:Refresh()	                             

Return .T. 

// Função que salva os dados da logomarca para guardar na variável kLogomarca
Static Function SairLogomarca()

   // Consiste dados antes de salvar na variável
   If lLogomarca == .T.
      If Empty(Alltrim(cLogomarca))
         Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nome do arquivo de logomarca não selecionado." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif
      
      If Empty(Alltrim(cColuna))
         Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Coluna de impressão da logomarca não informada." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif
                   
      If Empty(Alltrim(cSaltoLin))
         Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Qtd de salto de linhas não informado." + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif

      If Empty(Alltrim(cLargura))
         Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Largura da imagem não definida. Verifique!" + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif

      If Empty(Alltrim(cAltura))
         Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Altura da imagem não definida. Verifique!" + chr(13) + chr(10) + "Verifique!")
         Return(.T.)
      Endif

   Endif
   
   kLogomarca := ""
   kLogomarca := IIF(lLogomarca == .F., "N", "S") + "|" + Alltrim(cLogomarca) + "|" + cColuna + "|" + cSaltoLin + "|" + cLargura + "|" + cAltura + "|"

   // Envia para a função que grava os parâmetros no array aParametros
   Gravaparametros("[L]", 1, IIF(lLogomarca == .F., "N", "S") + "|" + Alltrim(cLogomarca) + "|" + cColuna + "|" + cSaltoLin + "|" + cLargura + "|" + cAltura + "|")

   oDlgLogo:End()
   
Return(.T.)

// Função que grava o array aParametros
Static Function Gravaparametros(_Identificador, _Sequencia, _Conteudo)

   Local nContar   := 0
   Local lJaExiste := .F.
   
   // Verifica se o parâmetro já existe
   lJaExiste := .F.
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == _Identificador .And. aParametros[nContar,02] = _Sequencia
          aParametros[nContar,02] := _Sequencia
          aParametros[nContar,03] := _Conteudo
          lJaExiste := .T.
          Exit
       Endif
   Next nContar
   
   If lJaExiste == .F.
      aAdd( aParametros, { _Identificador, _Sequencia, _Conteudo } )
   Endif

   a := 1
   
Return(.T.)      

// Função que gera relatório no padrão Protheus
Static Function GeraRelPadrao()

   Local nContar    := 0
   Local lExistePar := .F.

   // Verifica se já existe configuração de relatório. Se não existir, envia para o gerador default de relatório
   lExistePar := .F.

   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[P]" .Or. ;
          aParametros[nContar,01] == "[C]" .Or. ;
          aParametros[nContar,01] == "[D]"
          lExistePar := .T.
          Exit
       Endif
   Next nContar
          
   If lExistePar == .F.
      GERADEFAULT(9)
      Return(.T.)
   Else

      MsgRun("Aguarde! Gerando relatório para visualização ...", "Relatório",{|| xGeraRelPadrao() })
   
   Endif

Return(.T.)

// Função que gera relatório no padrão Protheus
Static Function xGeraRelPadrao()

   Local nContar   := 0
   Local nOrdem
   Local cEmpresa  := ""
   Local cData     := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto  := 0
   Local nServico  := 0

   Private oPrint

   Private nLimvert        := 0
   Private nPagina         := 0
   Private _nLin           := 0
   Private aPesquisa       := {}
   Private cEmail          := ""
   Private cReduzido       := ""
   Private aPaginas        := {}
   Private cErroEnvio      := 0
   Private aTempo          := {}
   Private __TipoImpressao := Space(02)
   Private __GrupoQuebra   := Space(01)
   Private __QtdQuebras    := 0
   Private aCampoQuebra    := {}
   Private __Totalizador   := Space(01)
   Private __LinhasPagina  := 0

   // Pesquisa os parâmetros gerais do relatório
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[P]"
          __TipoImpressao := Substr(U_P_CORTA(aParametros[nContar,03], "|", 1),01,02)
          __LinhasPagina  := INT(VAL(U_P_CORTA(aParametros[nContar,03], "|", 4)))
          Exit
      Endif
   Next nContar

   // Verifica se existe indicação de grupo de quebra no relatório
   __GrupoQuebra == "N"

   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[Q]"
          __GrupoQuebra == "S"          
          Exit
       Endif
   Next nContar       

   // Verifica se existe indicação de Totalizadores no relatório
   __Totalizador := "N"

   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[Z]"
          __Totalizador == "S"          
          Exit
       Endif
   Next nContar       

   // Calibra a quantidade de linhas por página a ser impressa
   nLimvert := __LinhasPagina

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()

   If __TipoImpressao == "01"
      oPrint:SetPortrait()  // Para Retrato
   Else  
      oPrint:SetLandScape() // Para Paisagem
   Endif

   oPrint:SetPaperSize(9) // A4

   // Controle numeração de páginas
   nPagina  := 0
   _nLin    := 10
      
   // ###########################################################
   // Envia para a função que imprime o cabeçalho do relatório ##
   // ###########################################################
   CABECARELATO()

   // ###################################
   // Imprime os detalhes do relatório ##
   // ###################################

   If __GrupoQuebra == "N"

      aCampoTotal := {}
      aTotalGeral := {}

      For nContar = 1 to Len(aData)
                                 
          // Envia para função que imprime os detalhes do relatório
          Print_Detalhes(nContar)
       
      Next nContar       

   Else

      // ###############################################################################
      // Carrega o array com a quantidade de grupos de quebra existentes no relatório ##
      // ###############################################################################
      aCampoQuebra := {}
      __QtdQuebras := 0

      For nContar = 1 to Len(aParametros)
          If aParametros[nContar,01] == "[Q]"
             If Substr(U_P_CORTA(aParametros[nContar,03], "|", 2),01,02) == "SS"
                Loop
             Else   
                __QtdQuebras += 1
                aAdd( aCampoQuebra, Alltrim(U_P_CORTA(aParametros[nContar,03], "|", 2)))
             Endif   
          Endif
      Next nContar
   
      // ########################################################################
      // Carrega o array com a quantidade de campos totalizadores no relatório ##
      // ########################################################################
      aCampoTotal := {}
      aTotalGeral := {}
      __QtdTotal  := 0

      For nContar = 1 to Len(aParametros)
          If aParametros[nContar,01] == "[Z]"
             If Substr(U_P_CORTA(aParametros[nContar,03], "|", 2),01,02) == "SS"
                Loop
             Else   
                __QtdTotal += 1

                // Inicializa o array que guardará os valor para impressão dos totais das quebras no final de cada quebra de grupo totalizador
                aAdd( aCampoTotal, { Alltrim(U_P_CORTA(aParametros[nContar,03], "|", 2)),; // 01 - Nome do Campo Totalizador
                                     0                                                  ,; // 02 - Valor Acumulado a ser impresso
                                     U_P_CORTA(aParametros[nContar,03], "|", 4)         ,; // 03 - Posição de Impressão
                                     U_P_CORTA(aParametros[nContar,03], "|", 3)         ,; // 04 - Fonte de Impressão
                                     U_P_CORTA(aParametros[nContar,03], "|", 5)         ,; // 05 - Nº de linhas para salto
                                     U_P_CORTA(aParametros[nContar,03], "|", 6)         ,; // 06 - Tipo de Campo
                                     U_P_CORTA(aParametros[nContar,03], "|", 8)         }) // 07 - Máscara de impressão

                // Inicializa o array que guardará os valor para impressão dos totais das quebras no final do relatório
                aAdd( aTotalGeral, { Alltrim(U_P_CORTA(aParametros[nContar,03], "|", 2)),; // 01 - Nome do Campo Totalizador
                                     0                                                  ,; // 02 - Valor Acumulado a ser impresso
                                     U_P_CORTA(aParametros[nContar,03], "|", 4)         ,; // 03 - Posição de Impressão
                                     U_P_CORTA(aParametros[nContar,03], "|", 3)         ,; // 04 - Fonte de Impressão
                                     U_P_CORTA(aParametros[nContar,03], "|", 5)         ,; // 05 - Nº de linhas para salto
                                     U_P_CORTA(aParametros[nContar,03], "|", 6)         ,; // 06 - Tipo de Campo
                                     U_P_CORTA(aParametros[nContar,03], "|", 8)         }) // 07 - Máscara de impressão


             Endif   
          Endif
      Next nContar

      // #############################################
      // Início da impressão dos dados do relatório ##
      // #############################################
      Do Case 
        
         // Em caso de ter indicação de quebra porém nenhuma quebra foi parametrizada
         Case __QtdQuebras == 0

              For nContar = 1 to Len(aData)

                  // Envia para função que imprime os detalhes do relatório
                  Print_Detalhes(nContar)

              Next nContar       

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // #########################
         // Imprime com Uma Quebra ##
         // #########################
         Case __QtdQuebras == 1

              // Carrega para a variável q_01Quebra o conteúdo do campo para comparação
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da quebra
              Print_Quebra(nPosQ01, q_01Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)
                  If aData[nContar,nPosQ01] == q_01Quebra
                     // Envia para função que imprime os detalhes do relatório
                     Print_Detalhes(nContar)
                  Else

                     // Imprime os totais do grupo
                     Print_TGrupo()

                     q_01Quebra := aData[nContar,nPosQ01]

                     // Imprime os dados da quebra
                     Print_Quebra(nPosQ01, q_01Quebra)

                     nContar := nContar -1

                  Endif

              Next nContar      
              
              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ##########################
         // Imprime com Duas Quebra ##
         // ##########################
         Case __QtdQuebras == 2

              // Carrega para a variável q_01Quebra o conteúdo do campo para comparação
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Primeira Quebras
              Print_Quebra(nPosQ01, q_01Quebra)

              // Carrega para a variável q_01Quebra o conteúdo do campo para comparação
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Segunda quebra
              Print_Quebra(nPosQ02, q_02Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra

                     If aData[nContar,nPosQ02] == q_02Quebra
                        // Envia para função que imprime os detalhes do relatório
                        Print_Detalhes(nContar)
                     Else

                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]

                        // Imprime os dados da Segunda Quebra
                        Print_Quebra(nPosQ02, q_02Quebra)

                        nContar := nContar -1

                     Endif

                   Else

                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]

                      // Imprime os dados da Primeira Quebra
                      Print_Quebra(nPosQ01, q_01Quebra)

                      nContar := nContar -1

                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ###########################
         // Imprime com Três Quebras ##
         // ###########################
         Case __QtdQuebras == 3

              // Carrega para a variável q_01Quebra o conteúdo do campo para comparação
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Primeira Quebra
              Print_Quebra(nPosQ01, q_01Quebra)

              // Carrega para a variável q_02Quebra o conteúdo do campo para comparação
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Segunda quebra
              Print_Quebra(nPosQ02, q_02Quebra)

              // Carrega para a variável q_03Quebra o conteúdo do campo para comparação
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Segunda quebra
              Print_Quebra(nPosQ03, q_03Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra

                     If aData[nContar,nPosQ02] == q_02Quebra

                        If aData[nContar,nPosQ03] == q_03Quebra
                           // Envia para função que imprime os detalhes do relatório
                           Print_Detalhes(nContar)
                        Else

                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           // Imprime os dados da Terceira Quebra
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                           
                        Endif   
                        
                     Else
                        
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]

                        // Imprime os dados da Terceira Quebra
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1

                      Endif

                   Else

                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]

                      // Imprime os dados da Primeira Quebra
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1

                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // #############################
         // Imprime com Quatro Quebras ##
         // #############################
         Case __QtdQuebras == 4

              // Carrega para a variável q_01Quebra o conteúdo do campo para comparação
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Primeira Quebra
              Print_Quebra(nPosQ01, q_01Quebra)

              // Carrega para a variável q_02Quebra o conteúdo do campo para comparação
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da Segunda quebra
              Print_Quebra(nPosQ02, q_02Quebra)

              // Carrega para a variável q_03Quebra o conteúdo do campo para comparação
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da terceira quebra
              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              // Imprime os dados da terceira quebra
              Print_Quebra(nPosQ04, q_04Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              // Envia para função que imprime os detalhes do relatório
                              Print_Detalhes(nContar)
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ############################
         // Imprime com Cinco Quebras ##
         // ############################
         Case __QtdQuebras == 5

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 // Envia para função que imprime os detalhes do relatório
                                 Print_Detalhes(nContar)
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ###########################
         // Imprime com Seis Quebras ##
         // ###########################
         Case __QtdQuebras == 6

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // ====> Q_06Quebra
              For nPosQ06 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ06]) == aCampoQuebra[6]
                     q_06Quebra := aData[01,nPosQ06]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ06, q_06Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 If aData[nContar,nPosQ06] == q_06Quebra
                                    // Envia para função que imprime os detalhes do relatório
                                    Print_Detalhes(nContar)
                                 Else
                                    // Imprime os totais do grupo
                                    Print_TGrupo()

                                    q_06Quebra := aData[nContar,nPosQ06]
                                    Print_Quebra(nPosQ06, q_06Quebra)
                                    nContar := nContar -1
                                 Endif                                     
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ###########################
         // Imprime com Sete Quebras ##
         // ###########################
         Case __QtdQuebras == 7

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // ====> Q_06Quebra
              For nPosQ06 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ06]) == aCampoQuebra[6]
                     q_06Quebra := aData[01,nPosQ06]
                     Exit
                  Endif
              Next nContar                         

              // ====> Q_07Quebra
              For nPosQ07 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ07]) == aCampoQuebra[7]
                     q_07Quebra := aData[01,nPosQ07]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ07, q_07Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 If aData[nContar,nPosQ06] == q_06Quebra
                                    If aData[nContar,nPosQ07] == q_07Quebra
                                       // Envia para função que imprime os detalhes do relatório
                                       Print_Detalhes(nContar)
                                    Else   
                                       // Imprime os totais do grupo
                                       Print_TGrupo()

                                       q_07Quebra := aData[nContar,nPosQ07]
                                       Print_Quebra(nPosQ07, q_07Quebra)
                                       nContar := nContar -1
                                    Endif                                     
                                 Else
                                    // Imprime os totais do grupo
                                    Print_TGrupo()

                                    q_06Quebra := aData[nContar,nPosQ06]
                                    Print_Quebra(nPosQ06, q_06Quebra)
                                    nContar := nContar -1
                                 Endif                                     
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ###########################
         // Imprime com Oito Quebras ##
         // ###########################
         Case __QtdQuebras == 8

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // ====> Q_06Quebra
              For nPosQ06 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ06]) == aCampoQuebra[6]
                     q_06Quebra := aData[01,nPosQ06]
                     Exit
                  Endif
              Next nContar                         

              // ====> Q_07Quebra
              For nPosQ07 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ07]) == aCampoQuebra[7]
                     q_07Quebra := aData[01,nPosQ07]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ07, q_07Quebra)

              // ====> Q_08Quebra
              For nPosQ08 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ08]) == aCampoQuebra[8]
                     q_08Quebra := aData[01,nPosQ08]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ08, q_08Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 If aData[nContar,nPosQ06] == q_06Quebra
                                    If aData[nContar,nPosQ07] == q_07Quebra
                                       If aData[nContar,nPosQ08] == q_08Quebra
                                          // Envia para função que imprime os detalhes do relatório
                                          Print_Detalhes(nContar)
                                       Else   
                                          // Imprime os totais do grupo
                                          Print_TGrupo()

                                          q_08Quebra := aData[nContar,nPosQ08]
                                          Print_Quebra(nPosQ08, q_08Quebra)
                                          nContar := nContar -1
                                       Endif                                     
                                    Else   
                                       // Imprime os totais do grupo
                                       Print_TGrupo()

                                       q_07Quebra := aData[nContar,nPosQ07]
                                       Print_Quebra(nPosQ07, q_07Quebra)
                                       nContar := nContar -1
                                    Endif                                     
                                 Else
                                    // Imprime os totais do grupo
                                    Print_TGrupo()

                                    q_06Quebra := aData[nContar,nPosQ06]
                                    Print_Quebra(nPosQ06, q_06Quebra)
                                    nContar := nContar -1
                                 Endif                                     
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ###########################
         // Imprime com Nove Quebras ##
         // ###########################
         Case __QtdQuebras == 9

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // ====> Q_06Quebra
              For nPosQ06 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ06]) == aCampoQuebra[6]
                     q_06Quebra := aData[01,nPosQ06]
                     Exit
                  Endif
              Next nContar                         

              // ====> Q_07Quebra
              For nPosQ07 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ07]) == aCampoQuebra[7]
                     q_07Quebra := aData[01,nPosQ07]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ07, q_07Quebra)

              // ====> Q_08Quebra
              For nPosQ08 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ08]) == aCampoQuebra[8]
                     q_08Quebra := aData[01,nPosQ08]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ08, q_08Quebra)

              // ====> Q_09Quebra
              For nPosQ09 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ09]) == aCampoQuebra[9]
                     q_09Quebra := aData[01,nPosQ09]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ09, q_09Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 If aData[nContar,nPosQ06] == q_06Quebra
                                    If aData[nContar,nPosQ07] == q_07Quebra
                                       If aData[nContar,nPosQ08] == q_08Quebra
                                          If aData[nContar,nPosQ09] == q_09Quebra
                                             // Envia para função que imprime os detalhes do relatório
                                             Print_Detalhes(nContar)
                                          Else   
                                             // Imprime os totais do grupo
                                             Print_TGrupo()

                                             q_09Quebra := aData[nContar,nPosQ09]
                                             Print_Quebra(nPosQ09, q_09Quebra)
                                             nContar := nContar -1
                                          Endif                                     
                                       Else   
                                          // Imprime os totais do grupo
                                          Print_TGrupo()

                                          q_08Quebra := aData[nContar,nPosQ08]
                                          Print_Quebra(nPosQ08, q_08Quebra)
                                          nContar := nContar -1
                                       Endif                                     
                                    Else   
                                       // Imprime os totais do grupo
                                       Print_TGrupo()

                                       q_07Quebra := aData[nContar,nPosQ07]
                                       Print_Quebra(nPosQ07, q_07Quebra)
                                       nContar := nContar -1
                                    Endif                                     
                                 Else
                                    // Imprime os totais do grupo
                                    Print_TGrupo()

                                    q_06Quebra := aData[nContar,nPosQ06]
                                    Print_Quebra(nPosQ06, q_06Quebra)
                                    nContar := nContar -1
                                 Endif                                     
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

         // ##########################
         // Imprime com Dez Quebras ##
         // ##########################
         Case __QtdQuebras == 10

              // ====> Q_01Quebra
              For nPosQ01 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ01]) == aCampoQuebra[1]
                     q_01Quebra := aData[01,nPosQ01]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ01, q_01Quebra)

              // ====> Q_02Quebra
              For nPosQ02 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ02]) == aCampoQuebra[2]
                     q_02Quebra := aData[01,nPosQ02]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ02, q_02Quebra)

              // ====> Q_03Quebra
              For nPosQ03 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ03]) == aCampoQuebra[3]
                     q_03Quebra := aData[01,nPosQ03]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ03, q_03Quebra)

              // ====> Q_04Quebra
              For nPosQ04 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ04]) == aCampoQuebra[4]
                     q_04Quebra := aData[01,nPosQ04]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ04, q_04Quebra)

              // ====> Q_05Quebra
              For nPosQ05 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ05]) == aCampoQuebra[5]
                     q_05Quebra := aData[01,nPosQ05]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ05, q_05Quebra)

              // ====> Q_06Quebra
              For nPosQ06 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ06]) == aCampoQuebra[6]
                     q_06Quebra := aData[01,nPosQ06]
                     Exit
                  Endif
              Next nContar                         

              // ====> Q_07Quebra
              For nPosQ07 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ07]) == aCampoQuebra[7]
                     q_07Quebra := aData[01,nPosQ07]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ07, q_07Quebra)

              // ====> Q_08Quebra
              For nPosQ08 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ08]) == aCampoQuebra[8]
                     q_08Quebra := aData[01,nPosQ08]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ08, q_08Quebra)

              // ====> Q_09Quebra
              For nPosQ09 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ09]) == aCampoQuebra[9]
                     q_09Quebra := aData[01,nPosQ09]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ09, q_09Quebra)

              // ====> Q_10Quebra
              For nPosQ10 = 1 to Len(aHead)
                  If Alltrim(ahead[nPosQ10]) == aCampoQuebra[10]
                     q_10Quebra := aData[01,nPosQ10]
                     Exit
                  Endif
              Next nContar                         

              Print_Quebra(nPosQ10, q_10Quebra)

              // Imprime os detalhes do relatório
              For nContar = 1 to Len(aData)

                  If aData[nContar,nPosQ01] == q_01Quebra
                     If aData[nContar,nPosQ02] == q_02Quebra
                        If aData[nContar,nPosQ03] == q_03Quebra
                           If aData[nContar,nPosQ04] == q_04Quebra
                              If aData[nContar,nPosQ05] == q_05Quebra
                                 If aData[nContar,nPosQ06] == q_06Quebra
                                    If aData[nContar,nPosQ07] == q_07Quebra
                                       If aData[nContar,nPosQ08] == q_08Quebra
                                          If aData[nContar,nPosQ09] == q_09Quebra
                                             If aData[nContar,nPosQ10] == q_10Quebra
                                                // Envia para função que imprime os detalhes do relatório
                                                Print_Detalhes(nContar)
                                             Else   
                                                // Imprime os totais do grupo
                                                Print_TGrupo()

                                                q_10Quebra := aData[nContar,nPosQ10]
                                                Print_Quebra(nPosQ10, q_10Quebra)
                                                nContar := nContar -1
                                             Endif                                     
                                          Else   
                                             // Imprime os totais do grupo
                                             Print_TGrupo()

                                             q_09Quebra := aData[nContar,nPosQ09]
                                             Print_Quebra(nPosQ09, q_09Quebra)
                                             nContar := nContar -1
                                          Endif                                     
                                       Else   
                                          // Imprime os totais do grupo
                                          Print_TGrupo()

                                          q_08Quebra := aData[nContar,nPosQ08]
                                          Print_Quebra(nPosQ08, q_08Quebra)
                                          nContar := nContar -1
                                       Endif                                     
                                    Else   
                                       // Imprime os totais do grupo
                                       Print_TGrupo()

                                       q_07Quebra := aData[nContar,nPosQ07]
                                       Print_Quebra(nPosQ07, q_07Quebra)
                                       nContar := nContar -1
                                    Endif                                     
                                 Else
                                    // Imprime os totais do grupo
                                    Print_TGrupo()

                                    q_06Quebra := aData[nContar,nPosQ06]
                                    Print_Quebra(nPosQ06, q_06Quebra)
                                    nContar := nContar -1
                                 Endif                                     
                              Else
                                 // Imprime os totais do grupo
                                 Print_TGrupo()

                                 q_05Quebra := aData[nContar,nPosQ05]
                                 Print_Quebra(nPosQ05, q_05Quebra)
                                 nContar := nContar -1
                              Endif
                           Else
                              // Imprime os totais do grupo
                              Print_TGrupo()

                              q_04Quebra := aData[nContar,nPosQ04]
                              Print_Quebra(nPosQ04, q_04Quebra)
                              nContar := nContar -1
                           Endif
                        Else         
                           // Imprime os totais do grupo
                           Print_TGrupo()

                           q_03Quebra := aData[nContar,nPosQ03]
                           Print_Quebra(nPosQ03, q_03Quebra)
                           nContar := nContar -1
                        Endif   
                     Else
                        // Imprime os totais do grupo
                        Print_TGrupo()

                        q_02Quebra := aData[nContar,nPosQ02]
                        Print_Quebra(nPosQ02, q_02Quebra)
                        nContar := nContar -1
                     Endif
                   Else
                      // Imprime os totais do grupo
                      Print_TGrupo()

                      q_01Quebra := aData[nContar,nPosQ01]
                      Print_Quebra(nPosQ01, q_01Quebra)
                      nContar := nContar -1
                   Endif
                     
              Next nContar      

              // Imprime os totais do grupo
              Print_TGrupo()

              // Imprime os totais gerais do relatorio
              Print_TGeral()

       EndCase        
   
   Endif
      
   // Envia para a função que imprime o rodapé do relatório
   Print_Rodape()

   // Encerra Relatório
   // -----------------
   oPrint:EndPage()

   // Preview do Relatório
   // --------------------
   oPrint:Preview()

   MS_FLUSH()

Return .T.

// ###################################
// Imprime o cabeçalho do relatório ##
// ###################################
Static Function CABECARELATO()

   Local nContar     := 0

   // Início da impressão conforme parâmetros
   // ---------------------------------------
   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
                          
   // Função que imprime a logomarca do relatório
   // -------------------------------------------
   Print_Logomarca()

   // Função que imprime a identidicação do relatório
   // -----------------------------------------------
   Print_Identifica()

   // Função que imprime o cabeçalho do relatório
   // -------------------------------------------
   Print_Cabecalho()

Return .T.

// ########################################
// Função que pula a página de impressão ##
// ########################################
Static Function VerPagina()

   If _nLin > nLimVert - 10

      // Envia para a função que imprime o rodapé do relatório
      Print_Rodape()

      oPrint:EndPage()

      // Envia para a função que imprime o cabeçalho do relatório
      CABECARELATO()

   Endif
   
Return .T.

// ##############################################
// Função que imprime a Logomarca do relatório ##
// ##############################################
Static Function Print_Logomarca()

   Local nContar := 0

   For nContar = 1 to Len(aParametros)

       If aParametros[nContar,01] == "[L]"
          If U_P_CORTA(aParametros[nContar,03], "|", 1) == "S"
             oPrint:SayBitmap( _nLin, INT(VAL(U_P_CORTA(aParametros[nContar,03], "|", 3))),;
                                      Alltrim(U_P_CORTA(aParametros[nContar,03], "|", 2)) ,;
                                      INT(VAL(U_P_CORTA(aParametros[nContar,03], "|", 5))),;
                                      INT(VAL(U_P_CORTA(aParametros[nContar,03], "|", 6))) )
             _nLin += INT(VAL(U_P_CORTA(aParametros[nContar,03], "|", 4)))
             Exit
          Endif
      Endif

   Next nContar
   
Return(.T.)

// #######################################
// Imprime a Identificação do relatório ##
// #######################################
Static Function Print_Identifica()

   Local nContar      := 0
   Local aRidentifica := {}
   
   // Carrega o array aRidentifica para ordenação antes da impressão
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[I]"
          aAdd(aRidentifica, { aParametros[nContar,03], U_P_CORTA(aParametros[nContar,03], "|", 8) } )
       Endif
   Next nContar
   
   // Ordena o array para impressão
   ASORT(aRidentifica,,,{ | x,y | x[2] < y[2] } )
   
   // Realiza a impressão na ordem estabelecida
   For nContar = 1 to Len(aRidentifica)

       Do Case
             
          // Imprime Nome da Empresa
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "01"
               xFonte := MontaFonte(U_P_CORTA(aRidentifica[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), Alltrim(U_P_CORTA(aRidentifica[nContar,01], "|", 3)), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Imprime o Título do Relatório
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "02"
               xFonte := MontaFonte(U_P_CORTA(aRidentifica[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), Alltrim(U_P_CORTA(aRidentifica[nContar,01], "|", 3)), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Imprime Data e Hora
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "03"
               xFonte := MontaFonte(U_P_CORTA(aRidentifica[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), Dtoc(Date()) + " - " + Time(), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Filtro do Relatório
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "04"
               xFonte := MontaFonte(U_P_CORTA(aRidentifica[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), Alltrim(Strtran(kTituloR, "?", ":")), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Nova Linha de impressão
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "06"
               _nLin += INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 6)))
                  
          // Linha Separadora
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "07"
               oPrint:Line( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 7))))

          // Página
          Case Substr(U_P_CORTA(aRidentifica[nContar,01], "|", 2),01,02) == "08"
               xFonte := MontaFonte(U_P_CORTA(aRidentifica[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRidentifica[nContar,01], "|", 5))), "Página: " + Strzero(nPagina,5), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

       EndCase
          
   Next nContar       

Return(.T.)

// ##############################################
// Função que imprime o cabeçalho do relatório ##
// ##############################################
Static Function Print_Cabecalho()

   Local nContar     := 0
   Local aRcabecalho := {}

   // Carrega o array aRcabecalho para ordenação antes da impressão
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[C]"
          aAdd(aRcabecalho, { aParametros[nContar,03], U_P_CORTA(aParametros[nContar,03], "|", 7) } )
       Endif
   Next nContar
   
   // Ordena o array para impressão
   ASORT(aRcabecalho,,,{ | x,y | x[2] < y[2] } )

   // Realiza a impressão do Cabeçalho
   For nContar = 1 to Len(aRcabecalho)

       Do Case

          // Nova Linha de impressão
          Case Substr(U_P_CORTA(aRcabecalho[nContar,01], "|", 2),01,02) == "SS"
               _nLin += INT(VAL(U_P_CORTA(aRcabecalho[nContar,01], "|", 5)))
                  
          // Linha Separadora
          Case Substr(U_P_CORTA(aRcabecalho[nContar,01], "|", 2),01,02) == "LL"
               oPrint:Line( _nLin, INT(VAL(U_P_CORTA(aRcabecalho[nContar,01], "|", 4))), _nLin, INT(VAL(U_P_CORTA(aRcabecalho[nContar,01], "|", 6))))

          // Demais Campos
          Otherwise
               xFonte := MontaFonte(U_P_CORTA(aRcabecalho[nContar,01], "|", 3))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRcabecalho[nContar,01], "|", 4))), Alltrim(U_P_CORTA(aRcabecalho[nContar,01], "|", 2)), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

       EndCase
      
   Next nContar                    

Return(.T.)

// ##############################################
// Função que imprime os detalhes do relatório ##
// ##############################################
Static Function Print_Detalhes(nRegistroLido)

   Local nContar    := 0
   Local aRdetalhes := {}
   
   // Carrega o array aRcabecalho para ordenação antes da impressão
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[D]"
          aAdd(aRdetalhes, { aParametros[nContar,03], U_P_CORTA(aParametros[nContar,03], "|", 7) } )
       Endif
   Next nContar
   
   // Ordena o array para impressão
   ASORT(aRdetalhes,,,{ | x,y | x[2] < y[2] } )

   // Imprime os detalhes do relatório
   For nCampos = 1 to Len(aRdetalhes)

       Do Case
             
          // Imcremento de linha
          Case Substr(U_P_CORTA(aRdetalhes[nCampos,01], "|", 2),01,02) == "SS"
               _nLin += INT(VAL(U_P_CORTA(aRdetalhes[nCampos,01], "|", 5)))
               VerPagina()
                 
          Otherwise      

               // Pesquisa o conteúdo a ser impresso
               xCampo := Alltrim(U_P_CORTA(aRdetalhes[nCampos,01], "|", 2))
                      
               For nPosicaoHead = 1 to Len(aHead)
                   If Alltrim(aHead[nPosicaoHead]) == Alltrim(xCampo)
                      Exit
                   Endif
               Next nPosicaoHead       

               xFonte := MontaFonte(U_P_CORTA(aRdetalhes[nCampos,01], "|", 3))

               __TipoCampo := Substr(U_P_CORTA(aRdetalhes[nCampos,01], "|", 6),01,01)
               __Mascara   := Alltrim(U_P_CORTA(aRdetalhes[nCampos,01], "|", 8))

               Do Case
                  Case __TipoCampo == "N"
                       oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRdetalhes[nCampos,01], "|", 4))), TRANSFORM(VAL(aData[nRegistroLido,nPosicaoHead]), __Mascara), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
                  Case __TipoCampo == "D"
                       __CampoData := Substr(aData[nRegistroLido,nPosicaoHead],07,02) + "/" + Substr(aData[nRegistroLido,nPosicaoHead],05,02) + "/" + Substr(aData[nRegistroLido,nPosicaoHead],01,04)
                       oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRdetalhes[nCampos,01], "|", 4))), __CampoData, TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )                              
                  Otherwise                              
                       oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRdetalhes[nCampos,01], "|", 4))), aData[nRegistroLido,nPosicaoHead], TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
               EndCase

               // Verifica se o campo lido é um campo totalizador
               For nTotaliza = 1 to Len(aCampoTotal)
                   If Alltrim(Upper(aCampoTotal[nTotaliza,1])) == Alltrim(Upper(xCampo))
                      If aCampoTotal[nTotaliza,6] == "N"
                         aCampoTotal[nTotaliza,2] := aCampoTotal[nTotaliza,2] + VAL(aData[nRegistroLido,nPosicaoHead])
                         aTotalGeral[nTotaliza,2] := aTotalGeral[nTotaliza,2] + VAL(aData[nRegistroLido,nPosicaoHead])
                      Else
                         aCampoTotal[nTotaliza,2] := aCampoTotal[nTotaliza,2] + 1
                         aTotalGeral[nTotaliza,2] := aTotalGeral[nTotaliza,2] + 1
                      Endif                      
                   Endif
               Next nTotaliza       

       EndCase
       
   Next nCampos

Return(.T.)

// ###############################################################
// Função que imprime a quebra do relatório conforme parâmetros ##
// ###############################################################
Static Function Print_Quebra(__nPosQuebra, __Conteudo)

   Local nDetQuebra := 0
   Local aRquebras  := {}
   
   // Carrega o array aRcabecalho para ordenação antes da impressão
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[Q]"
          aAdd(aRquebras, { aParametros[nContar,03], U_P_CORTA(aParametros[nContar,03], "|", 7) } )
       Endif
   Next nContar
   
   // Ordena o array para impressão
   ASORT(aRquebras,,,{ | x,y | x[2] < y[2] } )

   // Imprime os dados da quebra
   For nDetQuebra = 1 to Len(aRquebras)

       If Alltrim(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 02)) == Alltrim(aHead[__nPosQuebra])
          xFonte := MontaFonte(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 3))

          Do Case

             Case Substr(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 6),01,01) == "D"
                  kk_Quebra := Alltrim(aHead[__nPosQuebra]) + ": " + Substr(__Conteudo,07,02) + "/" + Substr(__Conteudo,05,02) + "/" + Substr(__Conteudo,01,04)
                  oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 4))), kk_Quebra, TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

             Case Substr(U_P_CORTA(aParametros[nDetQuebra,03], "|", 6),01,01) == "N"
                  kk_Quebra := Alltrim(aHead[__nPosQquebra]) + ": " + TRANSFORM(VAL(__Conteudo), U_P_CORTA(aRquebras[nDetQuebra,01], "|", 8))
                  oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 4))), kk_Quebra, TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

             Otherwise
                  kk_Quebra := Alltrim(aHead[__nPosQuebra]) + ": " + Alltrim(__Conteudo)
                  oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 4))), kk_Quebra, TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )                                   

          EndCase

          If INT(VAL(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 5))) <> 0
             _nLin += INT(VAL(U_P_CORTA(aRquebras[nDetQuebra,01], "|", 5)))
             VerPagina()
          Endif                     

       Endif

   Next nDetQuebra

Return(.T.)

// ######################################################################
// Função que imprime os totais do grupo ou totais gerais do relatório ##
// ######################################################################
Static Function Print_TGrupo()

   Local nListaG   := 0
   Local lImprimiu := .F.

   // Adiciona um salto de linha para não imprimir colado no final do detalhe
   _nLin += 50

   // Verifica se pula de página
   VerPagina()

   // Imprime os totais
   For nListaG = 1 to Len(aCampoTotal)

       // Prepara o fonte a ser utilizado na impressão
       xFonte := MontaFonte(aCampoTotal[nListaG,04])

       If lImprimiu == .F.
//        oPrint:Say( _nLin, 50, "TOTAL DO GRUPO", TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
          lImprimiu := .T.
       Endif

       // Elabora a máscara de impressão do totalizador
       If u_p_occurs(aTotalGeral[nListaG,07],"9",1) == 0
          KKK_Mascara := "@!"
          KKK_Colunas := 0
       Else              
          If len(alltrim(str(aTotalGeral[nListaG,02]))) < u_p_occurs(aTotalGeral[nListaG,07],"9",1) 
             KKK_Mascara := aTotalGeral[nListaG,07]  
             KKK_Colunas := 0
          Else
             KKK_Mascara := "@E " + Replicate("9", u_p_occurs(aTotalGeral[nListaG,07],"9",1) + 3)
             KKK_Colunas := 1
          Endif
       Endif

       // Imprime o valor total
//     oPrint:Say( _nLin, INT(VAL( aCampoTotal[nListaG,03])), TRANSFORM(aCampoTotal[nListaG,02], aCampoTotal[nListaG,07]), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       
       If KKK_Colunas == 0
          oPrint:Say( _nLin, INT(VAL( aCampoTotal[nListaG,03])), TRANSFORM(aCampoTotal[nListaG,02], KKK_Mascara), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       Else
          oPrint:Say( _nLin, INT(VAL( aCampoTotal[nListaG,03])) - 50, TRANSFORM(aCampoTotal[nListaG,02], KKK_Mascara), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       Endif
       
       // Somente saltará de linha quando houver vaor no elemento lido
       If INT(VAL(aCampoTotal[nListaG,05])) <> 0

          _nLin += INT(VAL(aCampoTotal[nListaG,05]))

          // Verifica se pula de página
          VerPagina()

       Endif   

       // Zera o acumulador do totalizador da quebra de grupo para nova totalização
       aCampoTotal[nListaG,02] := 0

   Next nListaG

   _nLin += 50

   // Verifica se pula de página
   VerPagina()

Return(.T.)

// ###################################################
// Função que imprime os totais gerais do relatório ##
// ###################################################
Static Function Print_TGeral()

   Local nListaG   := 0
   Local lImprimiu := .F.

   // Adiciona um salto de linha para não imprimir colado no final do detalhe
   _nLin += 50

   // Verifica se pula de página
   VerPagina()

   // Imprime os totais
   For nListaG = 1 to Len(aTotalGeral)

       // Prepara o fonte a ser utilizado na impressão
       xFonte := MontaFonte(aTotalGeral[nListaG,04])

       If lImprimiu == .F.
//        oPrint:Say( _nLin, 50, "TOTAL GERAL", TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
          lImprimiu := .T.
       Endif
                                  
       If u_p_occurs(aTotalGeral[nListaG,07],"9",1) == 0
          KKK_Mascara := "@!"
          KKK_Colunas := 0
       Else              
          If len(alltrim(str(aTotalGeral[nListaG,02]))) < u_p_occurs(aTotalGeral[nListaG,07],"9",1) 
             KKK_Mascara := aTotalGeral[nListaG,07]
             KKK_Colunas := 0
          Else
             KKK_Mascara := "@E " + Replicate("9", u_p_occurs(aTotalGeral[nListaG,07],"9",1) + 3)
             KKK_Colunas := 1
          Endif
       Endif

       // Imprime o valor total
//     oPrint:Say( _nLin, INT(VAL( aTotalGeral[nListaG,03])), TRANSFORM(aTotalGeral[nListaG,02], aTotalGeral[nListaG,07]), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       
       If KKK_Colunas == 0
          oPrint:Say( _nLin, INT(VAL( aTotalGeral[nListaG,03])), TRANSFORM(aTotalGeral[nListaG,02], KKK_Mascara), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       Else
          oPrint:Say( _nLin, INT(VAL( aTotalGeral[nListaG,03])) - 50, TRANSFORM(aTotalGeral[nListaG,02], KKK_Mascara), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )
       Endif              

       // Somente saltará de linha quando houver vaor no elemento lido
       If INT(VAL(aTotalGeral[nListaG,05])) <> 0

          _nLin += INT(VAL(aTotalGeral[nListaG,05]))

          // Verifica se pula de página
          VerPagina()

       Endif   

   Next nListaG

   _nLin += 50

   // Verifica se pula de página
   VerPagina()

Return(.T.)

// #########################################
// Função que imprime o rodé do relatório ##
// #########################################
Static Function Print_Rodape()

   Local nContar  := 0
   Local aRrodape := {}
   
   // Carrega o array aRcabecalho para ordenação antes da impressão
   For nContar = 1 to Len(aParametros)
       If aParametros[nContar,01] == "[R]"
          aAdd(aRrodape, { aParametros[nContar,03], U_P_CORTA(aParametros[nContar,03], "|", 8) } )
       Endif
   Next nContar
   
   // Ordena o array para impressão
   ASORT(aRrodape,,,{ | x,y | x[2] < y[2] } )

   // Imprime o rodapé
   For nContar = 1 to Len(aRrodape)

       Do Case
             
          // Imprime Nome da Empresa
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "01"
               xFonte := MontaFonte(U_P_CORTA(aRrodape[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), Alltrim(U_P_CORTA(aRrodape[nContar,01], "|", 3)), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Imprime o Título do Relatório
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "02"
               xFonte := MontaFonte(U_P_CORTA(aRrodape[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), Alltrim(U_P_CORTA(aRrodape[nContar,01], "|", 3)), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Imprime Data e Hora
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "03"
               xFonte := MontaFonte(U_P_CORTA(aRrodape[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), Dtoc(Date()) + " - " + Time(), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Filtro do Relatório
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "04"
               xFonte := MontaFonte(U_P_CORTA(aRrodape[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), Alltrim(Strtran(kTituloR, "?", ":")), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

          // Nova Linha de impressão
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "06"
               _nLin += INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 6)))
                  
          // Linha Separadora
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "07"
               oPrint:Line( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 7))))

          // Página
          Case Substr(U_P_CORTA(aRrodape[nContar,01], "|", 2),01,02) == "08"
               xFonte := MontaFonte(U_P_CORTA(aRrodape[nContar,01], "|", 4))
               oPrint:Say( _nLin, INT(VAL(U_P_CORTA(aRrodape[nContar,01], "|", 5))), "Página: " + Strzero(nPagina,5), TFont():New( U_P_CORTA(xFonte,"|",1),, INT(VAL(U_P_CORTA(xFonte,"|",2))),, IIF(U_P_CORTA(xFonte,"|",3) == "S", .T., .F.),,,,.f.,.f. ) )

       EndCase
          
   Next nContar                    

Return(.T.)

// ###########################################
// Função que monta o fonte a ser utilizado ##
// ###########################################
Static Function MontaFonte(_FonteSelecionado)

   Local nVezes     := 0
   Local Nome_Fonte := ""

   If Empty(Alltrim(_FonteSelecionado))
      Return ""
   Endif               

   Do Case
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 1
           Nome_Fonte := "Arial|08|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 2
           Nome_Fonte := "Arial|09|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 3
           Nome_Fonte := "Arial|10|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 4
           Nome_Fonte := "Arial|11|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 5
           Nome_Fonte := "Arial|12|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 6           
           Nome_Fonte := "Arial|14|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 7
           Nome_Fonte := "Arial|16|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 8
           Nome_Fonte := "Arial|18|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 9
           Nome_Fonte := "Arial|20|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 10
           Nome_Fonte := "Arial|22|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 11
           Nome_Fonte := "Arial|24|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 12
           Nome_Fonte := "Arial|26|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 13
           Nome_Fonte := "Arial|28|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 14
           Nome_Fonte := "Arial|36|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 15
           Nome_Fonte := "Arial|48|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 16
           Nome_Fonte := "Arial|72|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 17
           Nome_Fonte := "Arial|08|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 18
           Nome_Fonte := "Arial|09|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 19
           Nome_Fonte := "Arial|10|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 20
           Nome_Fonte := "Arial|11|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 21
           Nome_Fonte := "Arial|12|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 22
           Nome_Fonte := "Arial|14|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 23
           Nome_Fonte := "Arial|16|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 24
           Nome_Fonte := "Arial|18|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 25
           Nome_Fonte := "Arial|20|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 26
           Nome_Fonte := "Arial|22|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 27
           Nome_Fonte := "Arial|24|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 28
           Nome_Fonte := "Arial|26|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 29
           Nome_Fonte := "Arial|28|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 30
           Nome_Fonte := "Arial|36|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 31
           Nome_Fonte := "Arial|48|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 32
           Nome_Fonte := "Arial|72|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 33
           Nome_Fonte := "Courier New|08|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 34
           Nome_Fonte := "Courier New|09|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 35
           Nome_Fonte := "Courier New|10|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 36
           Nome_Fonte := "Courier New|11|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 37
           Nome_Fonte := "Courier New|12|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 38
           Nome_Fonte := "Courier New|14|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 39
           Nome_Fonte := "Courier New|16|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 40
           Nome_Fonte := "Courier New|18|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 41
           Nome_Fonte := "Courier New|20|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 42
           Nome_Fonte := "Courier New|22|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 43
           Nome_Fonte := "Courier New|24|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 44
           Nome_Fonte := "Courier New|26|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 45
           Nome_Fonte := "Courier New|28|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 46
           Nome_Fonte := "Courier New|36|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 47
           Nome_Fonte := "Courier New|48|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 48
           Nome_Fonte := "Courier New|72|N|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 49
           Nome_Fonte := "Courier New|08|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 50
           Nome_Fonte := "Courier New|09|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 51
           Nome_Fonte := "Courier New|10|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 52
           Nome_Fonte := "Courier New|11|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 53
           Nome_Fonte := "Courier New|12|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 54
           Nome_Fonte := "Courier New|14|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 55
           Nome_Fonte := "Courier New|16|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 56
           Nome_Fonte := "Courier New|18|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 57
           Nome_Fonte := "Courier New|20|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 58
           Nome_Fonte := "Courier New|22|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 59
           Nome_Fonte := "Courier New|24|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 60
           Nome_Fonte := "Courier New|26|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 61
           Nome_Fonte := "Courier New|28|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 62
           Nome_Fonte := "Courier New|36|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 63
           Nome_Fonte := "Courier New|48|S|"
      Case Int(Val(Substr(_FonteSelecionado,01,02))) == 64
           Nome_Fonte := "Courier New|72|S|"
   EndCase

Return Nome_Fonte

// #####################################
// Função que cria o relatório padrão ##
// #####################################
Static Function GERADEFAULT(_TipoAbertura)

   Local nContar       := 0
   Local nLaco         := 0
   Local nPosicaoHead  := 0
   Local nTamCabecalho := 0 
   Local nTamConteudo  := 0
   Local nColunaIni    := 50
   Local aRelPadrao    := {}
   Local aTemporaria   := {}
   Local TipoSaida     := 0 && 1 - Retrato 2 - Paisagem
   Local nSequencia    := 0
   Local nCodigoLan    := 0
   Local nOrdenacao    := 0
   Local lImprimeCampo := "N"
   Local QtdCamposT    := 0
   Local nTotCampo     := 0

   // ###########################################################################################
   // Abre janela de configuração dos campos antes de calcular os posicionamentos de impressão ##
   // ###########################################################################################
   kk_Voltar_Rel := 0
   
   AbrCFGRelatorio(_TipoAbertura)
                  
//   If kk_Voltar_Rel == 2
//      Return(.T.)
//   Endif                   
   
   // ################################################################################# 
   // Elimina do array aParametros os parâmetros [I], [C] para receber nova gravação ##
   // #################################################################################
   For nContar = 1 to Len(aParametros)
      
       If aParametros[nContar,01] == "[I]" .Or. ;
          aParametros[nContar,01] == "[C]" .Or. ;
          aParametros[nContar,01] == "[D]" .Or. ;
          aParametros[nContar,01] == "[P]" .Or. ;          
          aParametros[nContar,01] == "[Q]" .Or. ;          
          aParametros[nContar,01] == "[Z]" .Or. ;          
          aParametros[nContar,01] == ""
          Loop
       Endif

       aAdd( aTemporaria, { aParametros[nContar,01],;
                            aParametros[nContar,02],;
                            aParametros[nContar,03]})
                            
   Next nContar                            

   // #############################
   // Recria o array aParametros ##
   // #############################
   aParametros := {}
   For nContar = 1 to Len(aTemporaria)
       aAdd( aparametros, { aTemporaria[nContar,01],;
                            aTemporaria[nContar,02],;
                            aTemporaria[nContar,03]})
                            
   Next nContar                            

   // ##########################################################################
   // Descobre o tipo de relatório a ser elaborado (1 - Retrato, 2 - Paisagem ##
   // ##########################################################################

   nColunaIni := 50

   For nContar = 1 to Len(aHead)
       
       // Posiciono no campo a ser parametrizado
       // aAdd( aCampos, aHead[nContar] )

       xCampo := Alltrim(aHead[nContar])
       
       nTamCabecalho := Len(Alltrim(xCampo))

       // Posiciona no conteúdo do campo lido para pesquisa o tamanho da informação
       For nPosicaoHead = 1 to Len(aHead)
           If Alltrim(aHead[nPosicaoHead]) == Alltrim(xCampo)
              Exit
           Endif
       Next nPosicaoHead       

       // Ordena o resltado para capcturar o tamanho da informação
       ASORT(aData,,,{ | x,y | x[nPosicaoHead] < y[nPosicaoHead] } )

       // Calcula o tamanho do conteúdo do campo
       nTamConteudo  := Len(aData[01,nPosicaoHead])

       // Pesquisa as características do campos a ser impresso
       For nBuscaMascara = 1 to Len(aModelos)
           // Verifica se o campo é ou não impresso 
           lImprimeCampo := "N"
           For nImprime = 1 to Len(aListax)
               If Alltrim(Upper(aListax[nImprime,04])) == Alltrim(Upper(xCampo))
                  lImprimeCampo := IIF(aListax[nImprime,01] == .T., "S", "N")
                  Exit
               Endif
           Next nImprime       

           If lImprimeCampo == "N"
              Exit
           Endif   

           If Alltrim(aModelos[nBuscaMascara,01]) == Alltrim(xCampo)
              xTipoCampo := aModelos[nBuscaMascara,02]
              xTamaCampo := aModelos[nBuscaMascara,03]
              xDeciCampo := aModelos[nBuscaMascara,04]       
              xMascCampo := aModelos[nBuscaMascara,05]       
              Exit
           Endif

       Next nContar       

       If lImprimeCampo == "N"
          Loop
       Endif   

       If nTamCabecalho  > nTamConteudo
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamCabecalho * 20) * 2)
          Else
             nColunaIni := nColunaIni + ((nTamCabecalho * 15) * 2)             
          Endif
       Else
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamConteudo  * 20) * 2)          
          Else
             nColunaIni := nColunaIni + ((nTamConteudo  * 15) * 2)          
          Endif                
       Endif   
       
   Next nContar

   If nColunaIni <= 2500
      aAdd(aParametros, { "[P]", 1, "01 - Retrato|N - Não|N - Não|3500 [F]" } )
      TipoSaida := 1
   Else
      aAdd(aParametros, { "[P]", 1, "02 - Paisagem|N - Não|N - Não|2300 [F]" } )      
      TipoSaida := 2
   Endif      

   // ##############################################################################################
   // Posiciona o cadastro de Empresa para impressão do nome da Empresa no cabeçalho do relatório ##
   // ##############################################################################################
   SM0->(DbSeek(cEmpAnt + cFilAnt))

   // ###################################################
   // Cria os parâmetros de Identificação do Relatório ##
   // ###################################################
   If TipoSaida == 1
      aAdd(aParametros, { "[I]",  1, "000001|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |2500 |00001|[F]" } )
      aAdd(aParametros, { "[I]",  2, "000002|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |20   |     |00005|[F]" } )
      aAdd(aParametros, { "[I]",  3, "000003|01 - Nome da Empresa|" + Alltrim(SM0->M0_NOMECOM) + "|35 - Courier New 10 - Normal|50   |     |     |00010|[F]" } )
      aAdd(aParametros, { "[I]",  4, "000004|02 - Título Relatório|RANKING DE FATURAMENTO|35 - Courier New 10 - Normal|1150 |     |     |00020|[F]" } )
      aAdd(aParametros, { "[I]",  5, "000005|03 - Data/hora|XX/XX/XXXX / XX:XX:XX|35 - Courier New 10 - Normal|2150 |     |     |00030|[F]" } )
      aAdd(aParametros, { "[I]",  6, "000006|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |40   |     |00040|[F]" } )
      aAdd(aParametros, { "[I]",  7, "000007|04 - Filtro|kTituloR|35 - Courier New 10 - Normal|50   |     |     |00050|[F]" } )
      aAdd(aParametros, { "[I]",  8, "000008|08 - Página|Página: 99999|35 - Courier New 10 - Normal|2150 |     |     |00060|[F]" } )
      aAdd(aParametros, { "[I]",  9, "000009|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |40   |     |00070|[F]" } )
      aAdd(aParametros, { "[I]", 10, "000010|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |2500 |00080|[F]" } )
      aAdd(aParametros, { "[I]", 11, "000011|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |20   |     |00090|[F]" } )
   Else

      aAdd(aParametros, { "[I]",  1, "000001|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |3220 |00001|[F]" } )
      aAdd(aParametros, { "[I]",  2, "000002|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |20   |     |00005|[F]" } )      
      aAdd(aParametros, { "[I]",  3, "000003|01 - Nome da Empresa|" + Alltrim(SM0->M0_NOMECOM) + "|35 - Courier New 10 - Normal|50   |     |     |00010|[F]" } )
      aAdd(aParametros, { "[I]",  4, "000004|02 - Título Relatório|RANKING DE FATURAMENTO|35 - Courier New 10 - Normal|1700 |     |     |00020|[F]" } )
      aAdd(aParametros, { "[I]",  5, "000005|03 - Data/hora|XX/XX/XXXX / XX:XX:XX|35 - Courier New 10 - Normal|2850 |     |     |00030|[F]" } )
      aAdd(aParametros, { "[I]",  6, "000006|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |40   |     |00040|[F]" } )
      aAdd(aParametros, { "[I]",  7, "000007|04 - Filtro|kTituloR|35 - Courier New 10 - Normal|50   |     |     |00050|[F]" } )
      aAdd(aParametros, { "[I]",  8, "000008|08 - Página|Página: 99999|35 - Courier New 10 - Normal|2850 |     |     |00060|[F]" } )
      aAdd(aParametros, { "[I]",  9, "000009|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |40   |     |00070|[F]" } )
      aAdd(aParametros, { "[I]", 10, "000010|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |3220 |00080|[F]" } )
      aAdd(aParametros, { "[I]", 11, "000011|06 - Nova Linha|NOVA LINHA|00 - Selecione a Fonte|     |20   |     |00090|[F]" } )
   Endif

   // ###############################################
   // Cria os parâmetros do cabeçalho do Relatório ##
   // ###############################################

   nColunaIni := 50

   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1

   For nContar = 1 to Len(aHead)

       // Posiciono no campo a ser parametrizado
       // aAdd( aCampos, aHead[nContar] )

       xCampo := Alltrim(aHead[nContar])
       
       // Verifica se o campo deve ou não ser impresso
       lImprimeCampo := "N"
       For nImprime = 1 to Len(aListax)
           If Alltrim(Upper(aListax[nImprime,04])) == Alltrim(Upper(xCampo))
              lImprimeCampo := IIF(aListax[nImprime,01] == .T., "S", "N")
              Exit
           Endif
       Next nImprime       

       If lImprimeCampo == "N"
          Loop
       Endif

// ############################################################################
//     // Verifica se o campo é um campo de quebra. Se for não imprime       ##
//     lImprimeCampo := "N"                                                  ##
//     For nImprime = 1 to Len(aListax)                                      ##
//         If Alltrim(Upper(aListax[nImprime,04])) == Alltrim(Upper(xCampo)) ##
//            lImprimeCampo := aListax[nImprime,02]                          ##
//            Exit                                                           ##
//         Endif                                                             ##
//     Next nImprime                                                         ##
//                                                                           ##
//     If lImprimeCampo == "S"                                               ##
//        Loop                                                               ##
//     Endif                                                                 ##
//                                                                           ##
// ############################################################################
  
       nTamCabecalho := Len(Alltrim(xCampo))

       // Posiciona no conteúdo do campo lido para pesquisa o tamanho da informação
       For nPosicaoHead = 1 to Len(aHead)
           If Alltrim(aHead[nPosicaoHead]) == Alltrim(xCampo)
              Exit
           Endif
       Next nPosicaoHead       

       // Ordena o resltado para capcturar o tamanho da informação
       ASORT(aData,,,{ | x,y | x[nPosicaoHead] < y[nPosicaoHead] } )

       // Calcula o tamanho do conteúdo do campo
       nTamConteudo  := Len(aData[01,nPosicaoHead])

       // Pesquisa as características do campos a ser impresso
       For nBuscaMascara = 1 to Len(aModelos)
           If Alltrim(aModelos[nBuscaMascara,01]) == Alltrim(xCampo)
              xTipoCampo := aModelos[nBuscaMascara,02]
              xTamaCampo := aModelos[nBuscaMascara,03]
              xDeciCampo := aModelos[nBuscaMascara,04]       
              xMascCampo := aModelos[nBuscaMascara,05]       
              Exit
           Endif
       Next nContar       

       // Verifica se deve colocar dados em nova linha
       If TipoSaida == 1
          If nColunaIni >= 2500
             nColunaIni := 50
             // Cria um saldo de linha
             aAdd( aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   |     |" + Strzero(nOrdenacao,5) + "|N|N|N|[F]" } )
             nSequencia += 1
             nCodigoLan += 1
             nOrdenacao += 10
          Endif   
       Else
          If nColunaIni >= 3200
             nColunaIni := 50
             // Cria um saldo de linha                                
             aAdd( aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   |     |" + Strzero(nOrdenacao,5) + "|N|N|N|[F]" } )
             nSequencia += 1
             nCodigoLan += 1
             nOrdenacao += 10
          Endif   
       Endif   

       // Localiza no array aListax as condições de impressão. Se campo imprime, Se campo é quebra e se campo é totalizador
       For nLocalizaC = 1 to Len(aListax)
           If Alltrim(Upper(aListax[nLocalizaC,04])) == Alltrim(Upper(xCampo))
              kk_Imprime  := IIF(aListax[nLocalizaC,01] == .T., "S", "N")
              kk_quebra   := aListax[nLocalizaC,02]
              kk_Totaliza := aListax[nLocalizaC,03]
              Exit
           Endif
       Next nLocaliza

       // Cria o parâmetro do detalhe a ser impresso
       aAdd(aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|" + Alltrim(xCampo) + "|" + "35 - Courier New 10 - Normal" + "|" + Alltrim(str(nColunaIni)) + "|" + "|" + "|" + Strzero(nOrdenacao,5) + "|" + kk_Imprime + "|" + kk_Quebra + "|" + kk_Totaliza + "|[F]" } )
       
       nSequencia += 1
       nCodigoLan += 1
       nOrdenacao += 10

       If nTamCabecalho  > nTamConteudo
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamCabecalho * 20) * 2)
          Else
             nColunaIni := nColunaIni + ((nTamCabecalho * 15) * 2)             
          Endif
       Else
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamConteudo  * 20) * 2)          
          Else
             nColunaIni := nColunaIni + ((nTamConteudo  * 15) * 2)          
          Endif                
       Endif   
       
   Next nContar
       
   // Cria um saldo de linha
   aAdd( aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   |     |" + Strzero(nOrdenacao,5) + "|N|N|N|[F]" } )

   nSequencia += 1
   nCodigoLan += 1
   nOrdenacao += 10

   // Cria uma linha contínua de separação do cabeçalho
   nTamLinha := IIF(TipoSaida == 1, 2500, 3220)
   
   // Cria o parâmetro do Cabeçalho
   aAdd( aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|LL - Linha Separadora|00 - Selecione a Fonte|50   |     |" + Alltrim(Str(nTamLInha)) + "|" + Strzero(nOrdenacao,5) + "|[F]" } )

   nSequencia += 1
   nCodigoLan += 1
   nOrdenacao += 10

   // Cria um saldo de linha
   aAdd( aParametros, { "[C]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   |     |" + Strzero(nOrdenacao,5) + "|[F]" } )

   // ###############################################
   // Cria os parâmetros dos detalhes do Relatório ##
   // ###############################################

   nColunaIni := 50

   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1

   For nContar = 1 to Len(aHead)
       
       // Posiciono no campo a ser parametrizado
       // aAdd( aCampos, aHead[nContar] )

       xCampo := Alltrim(aHead[nContar])
       
       // Verifica se o campo deve ou não ser impresso
       lImprimeCampo := "N"
       For nImprime = 1 to Len(aListax)
           If Alltrim(Upper(aListax[nImprime,04])) == Alltrim(Upper(xCampo))
              lImprimeCampo := IIF(aListax[nImprime,01] == .T., "S", "N")
              Exit
           Endif
       Next nImprime       

       If lImprimeCampo == "N"
          Loop
       Endif

// ##############################################################################
//     NÃO APAGAR. FICARÁ PARA A PRÓIMA RELEASE                                ##
//     // Verifica se o campo é um campo de quebra. Se for não imprime         ##
//       lImprimeCampo := "N"                                                  ##
//       For nImprime = 1 to Len(aListax)                                      ##
//           If Alltrim(Upper(aListax[nImprime,04])) == Alltrim(Upper(xCampo)) ##
//              lImprimeCampo := aListax[nImprime,02]                          ##
//              Exit                                                           ##
//           Endif                                                             ##
//       Next nImprime                                                         ##
//                                                                             ##
//       If lImprimeCampo == "S"                                               ##
//          Loop                                                               ##
//       Endif                                                                 ##
// ##############################################################################

       nTamCabecalho := Len(Alltrim(xCampo))

       // Posiciona no conteúdo do campo lido para pesquisa o tamanho da informação
       For nPosicaoHead = 1 to Len(aHead)
           If Alltrim(aHead[nPosicaoHead]) == Alltrim(xCampo)
              Exit
           Endif
       Next nPosicaoHead       

       // Ordena o resltado para capcturar o tamanho da informação
       ASORT(aData,,,{ | x,y | x[nPosicaoHead] < y[nPosicaoHead] } )

       // Calcula o tamanho do conteúdo do campo
       nTamConteudo  := Len(aData[01,nPosicaoHead])

       // Pesquisa as características do campos a ser impresso
       For nBuscaMascara = 1 to Len(aModelos)
           If Alltrim(aModelos[nBuscaMascara,01]) == Alltrim(xCampo)
              xTipoCampo := aModelos[nBuscaMascara,02]
              xTamaCampo := aModelos[nBuscaMascara,03]
              xDeciCampo := aModelos[nBuscaMascara,04]       
              xMascCampo := aModelos[nBuscaMascara,05]       
              Exit
           Endif
       Next nContar       

       // Verifica se deve colocar dados em nova linha
       If TipoSaida == 1
          If nColunaIni >= 2500
             nColunaIni := 50
             // Cria um saldo de linha
             aAdd( aParametros, { "[D]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   | |" + Strzero(nOrdenacao,5) + "|                    [F]" } )
             nSequencia += 1
             nCodigoLan += 1
             nOrdenacao += 10
          Endif   
       Else
          If nColunaIni >= 3200
             nColunaIni := 50
             // Cria um saldo de linha
             aAdd( aParametros, { "[D]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   | |" + Strzero(nOrdenacao,5) + "|                    [F]" } )
             nSequencia += 1
             nCodigoLan += 1
             nOrdenacao += 10
          Endif   
       Endif   

       // Inclui no array aRelPadrao os parâmetros de impressão do campo lido  
       aAdd(aParametros, { "[D]", nSequencia, Strzero(nCodigoLan,6) + "|" + Alltrim(xCampo) + "|" + "35 - Courier New 10 - Normal" + "|" + Alltrim(str(nColunaIni)) + "|" + "|" + xTipoCampo + "|" + Strzero(nOrdenacao,5) + "|" + xMascCampo + "|[F]" })

       nSequencia += 1
       nCodigoLan += 1
       nOrdenacao += 10

       If nTamCabecalho  > nTamConteudo
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamCabecalho * 20) * 2)
          Else
             nColunaIni := nColunaIni + ((nTamCabecalho * 15) * 2)             
          Endif
       Else
          If xTipoCampo == "N"
             nColunaIni := nColunaIni + ((nTamConteudo  * 20) * 2)          
          Else
             nColunaIni := nColunaIni + ((nTamConteudo  * 15) * 2)          
          Endif                
       Endif   

   Next nContar
       
   // Cria um saldo de linha
   aAdd( aParametros, { "[D]", nSequencia, Strzero(nCodigoLan,6) + "|SS - Salto de Linha|00 - Selecione a Fonte|     |50   | |" + Strzero(nOrdenacao,5) + "|                    [F]" } )

   // #############################
   // Cria o rodapé do Relatório ##
   // #############################
   If TipoSaida == 1
      aAdd(aParametros, { "[R]",  1, "000001|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |2500 |00001|[F]" } )
   Else
      aAdd(aParametros, { "[R]",  1, "000001|07 - Linha Separadora|LINHA SEPARADORA|35 - Courier New 10 - Normal|50   |50   |3220 |00001|[F]" } )
   Endif

   // ############################################
   // Cria os parâmetros de quebra do relatório ##
   // ############################################
   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1

   For nContar = 1 to Len(aListax)

       If aListax[nContar,01] == .F.
          Loop
       Endif
       
       If aListax[nContar,02] == "N"
          Loop
       Endif
     
       // Pesquisa a característica do campo
       x_Tipo_Campo := "C"
       x_Masc_Campo := "@!"

       For nLocaliza = 1 to Len(aParametros)
           If aParametros[nLocaliza,01] == "[D]"
              If Alltrim(Upper(U_P_CORTA(aParametros[nLocaliza,03], "|", 02))) == Alltrim(Upper(aListax[nContar,04]))
                 x_Tipo_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 06)
                 x_Masc_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 08)          
                 Exit
              Endif
           Endif
       Next nLocaliza          

       aAdd( aParametros, { "[Q]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|" + "51 - Courier New 10 - Negrito|50   |80   |" + x_Tipo_Campo + "|" + Strzero(nOrdenacao,5) + "|" + x_Masc_Campo + "|[F]" } )

       nSequencia += 1
       nCodigoLan += 1
       nOrdenacao += 10

   Next nContar

   // ######################################
   // Cria os parâmetros de totalizadores ##
   // ######################################

   // Conta quantos campos totalizadores foram indicado. Somente no último parâmetro do totalizador que gravação a quantidade de salto de linhas
   QtdCamposT := 0
   For nContar = 1 to Len(aListax)
       If aListax[nContar,03] == "S"      
          QtdCamposT += 1
       Endif
   Next nContar        

   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1
   nTotCampo  := 0

   For nContar = 1 to len(aListax)
 
       If aListax[nContar,01] == .F.
          Loop
       Endif
       
       If aListax[nContar,03] == "N"
          Loop
       endif

       // Pesquisa a característica do campo
       x_Tipo_Campo := "C"
       x_Masc_Campo := "@!"

       For nLocaliza = 1 to Len(aParametros)
           If aParametros[nLocaliza,01] == "[D]"
              If Alltrim(Upper(U_P_CORTA(aParametros[nLocaliza,03], "|", 02))) == Alltrim(Upper(aListax[nContar,04]))
                 x_Colu_campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 04)
                 x_Tipo_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 06)
                 x_Masc_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 08)          
                 Exit
              Endif
           Endif
       Next nLocaliza          

       nTotCampo += 1 

       If nTotCampo <> QtdCamposT
          nnSaldtoLin := 0
       Else
          nnSaldtoLin := 60             
       Endif
          
       aAdd( aParametros, { "[Z]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|" + "51 - Courier New 10 - Negrito|" + x_Colu_campo + "|" + Alltrim(Str(nnSaldtoLin)) + "|" + x_Tipo_Campo + "|" + Strzero(nOrdenacao,5) + "|" + x_Masc_Campo + "|[F]" } )

       nSequencia += 1
       nCodigoLan += 1
       nOrdenacao += 10

   Next nContar    

   // ############################################
   // Envia para a função que emite o relatório ##
   // ############################################
   If kk_Voltar_Rel == 1   
      If _TipoAbertura == 9
      Else
         GeraRelPadrao()
      Endif
   Endif
   
Return(.T.)

// ######################################################
// Função que abre a tela de configuração do relatório ##
// ######################################################
Static Function AbrCFGRelatorio(_TipoAbertura)

   Local lTemCampos := .F.
   Local nContar    := 0
   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local oMemo1
   Local oMemo2
   
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgCFG1

   kk_Voltar_Rel := 2

   // Carrega o array aListax com os campos da pesquisa realizada
   aListax := {}

   For ncontar = 1 to Len(aHead)
       aAdd( aListax, { .F., "N", "N",  aHead[nContar] } )   
   Next nContar

   // Captura os parâmetros já parametrizados pelo usuário para a pesquisa selecionada
   For nContar = 1 to Len(aListax)
       For nLocalizar = 1 to Len(aParametros)
           If aParametros[nLocalizar,01] == "[C]"   
              If Alltrim(Upper(U_P_CORTA(aParametros[nLocalizar,03], "|", 2))) == Alltrim(Upper(aListax[nContar,04]))              
                 aListax[nContar,01] := IIF(U_P_CORTA(aParametros[nLocalizar,03], "|", 08) == "S", .T., .F.)
                 aListax[nContar,02] := U_P_CORTA(aParametros[nLocalizar,03], "|", 09)
                 aListax[nContar,03] := U_P_CORTA(aParametros[nLocalizar,03], "|", 10)
                 Exit
              Endif
           Endif
       Next nLocalizar    
   Next nContar           
   
   // Desenha a tela para visualização
   If _TipoAbertura == 0
   
      DEFINE MSDIALOG oDlgCFG1 TITLE "Configurador de Relatório" FROM C(178),C(181) TO C(579),C(658) PIXEL

      @ C(005),C(005) Jpeg FILE "advpltools.png" Size C(126),C(026) PIXEL NOBORDER OF oDlgCFG1      

      @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(229),C(001) PIXEL OF oDlgCFG1

      @ C(184),C(005) Button "Quebra"      Size C(037),C(012) PIXEL OF oDlgCFG1 ACTION( MarcaQuebra(aListax[oListax:nAt,2]) )
      @ C(184),C(046) Button "Totalizador" Size C(037),C(012) PIXEL OF oDlgCFG1 ACTION( MarcaTotali(aListax[oListax:nAt,3]) )
      @ C(184),C(155) Button "Emitir"      Size C(037),C(012) PIXEL OF oDlgCFG1 ACTION( kk_Voltar_Rel := 1, oDlgCFG1:End() ) &&GravaImpQueTot() )
      @ C(184),C(196) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlgCFG1 ACTION( kk_Voltar_Rel := 2, oDlgCFG1:End() )

      @ 045,005 LISTBOX oListax FIELDS HEADER "Imprime", "Quebra", "Totaliza", "Campos do Relatório" PIXEL SIZE 290,188 OF oDlgCFG1 ON dblClick(aListax[oListax:nAt,1] := !aListax[oListax:nAt,1],oListax:Refresh())     
      oListax:SetArray( aListax )
      oListax:bLine := {||     {Iif(aListax[oListax:nAt,01],oOk,oNo),;
                                aListax[oListax:nAt,02]             ,;                         
                                aListax[oListax:nAt,03]             ,;            
                                aListax[oListax:nAt,04]}}                
                                
// ######################################################################
// SERÁ UTILIZADO NA NOVA RELEASE                                      ##
//    oListax:bLDblClick := {|| AltDetalhes( aListax[oListax:nAt,2] )} ##
// ######################################################################

      ACTIVATE MSDIALOG oDlgCFG1 CENTERED 
      
   Else
                       
      If _TipoAbertura = 9
         For nContar = 1 to Len(aListax)
             aListax[nContar,01] := .T.
         Next ncontar
      Endif       

      kk_Voltar_Rel := 1
      
   Endif
   
Return(.T.)

// ###############################################################
// Função que marca/desmarca a indicação de quebra de relatório ##
// ###############################################################
Static Function MarcaQuebra(_LinhaQuebra)

   If _LinhaQuebra == "N"
      aListax[oListax:nAt,2] := "S"
   Else
      aListax[oListax:nAt,2] := "N"      
   Endif

   oListax:SetArray( aListax )
   oListax:bLine := {||     {Iif(aListax[oListax:nAt,01],oOk,oNo),;
                             aListax[oListax:nAt,02]             ,;                         
                             aListax[oListax:nAt,03]             ,;            
                             aListax[oListax:nAt,04]}}
   
Return(.T.)      

// ####################################################################
// Função que marca/desmarca a indicação de totalizador de relatório ##
// ####################################################################
Static Function MarcaTotali(_LinhaTotal)

   If _LinhaTotal == "N"
      aListax[oListax:nAt,3] := "S"
   Else
      aListax[oListax:nAt,3] := "N"      
   Endif

   oListax:SetArray( aListax )
   oListax:bLine := {||     {Iif(aListax[oListax:nAt,01],oOk,oNo),;
                             aListax[oListax:nAt,02]             ,;                         
                             aListax[oListax:nAt,03]             ,;            
                             aListax[oListax:nAt,04]}}
   
Return(.T.)      

// ###################################################################
// Função que grava a indicação de impressão, grupo e totalizadores ##
// ###################################################################
Static Function GravaImpQueTot()
                             	
   Local nContar     := 0
   Local nLocaliza   := 0
   Local nSequencia  := 1
   Local nCodigoLan  := 1
   Local nOrdenacao  := 1
   Local aTemporaria := {}
   Local QtdCamposT  := 0
   Local nTotCampo   := 0
   Local nnSaldtoLin := 0

   // ######################################################################################## 
   // Elimina do array aParametros os parâmetros [X], [Q] e [Z]  para receber nova gravação ##
   // ########################################################################################
   For nContar = 1 to Len(aParametros)
      
       If aParametros[nContar,01] == "[X]" .Or. ;
          aParametros[nContar,01] == "[Q]" .Or. ;
          aParametros[nContar,01] == "[Z]" .Or. ;
          aParametros[nContar,01] == ""
          Loop
       Endif

       aAdd( aTemporaria, { aParametros[nContar,01],;
                            aParametros[nContar,02],;
                            aParametros[nContar,03]})
                            
   Next nContar                            

   // #############################
   // Recria o array aParametros ##
   // #############################
   aParametros := {}
   For nContar = 1 to Len(aTemporaria)
       aAdd( aparametros, { aTemporaria[nContar,01],;
                            aTemporaria[nContar,02],;
                            aTemporaria[nContar,03]})
                            
   Next nContar                            

   // Cria parâmetros de impressão de campos
   nSequencia := 1
   nCodigoLan := 1
   
   For nContar = 1 to len(aListax)

       // Verifica se o campo deve ou não ser impresso
       If aListax[nContar,01] == .F.
          aAdd( aParametros, { "[X]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|N|[F]"})          
       Else   
          aAdd( aParametros, { "[X]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|S|[F]"})          
       Endif   

       nSequencia += 1
       nCodigoLan += 1

   Next nContar    

   // Cria parâmetros de Grupo de Quebra
   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1
   
   For nContar = 1 to len(aListax)

       If aListax[nContar,02] == "S"

          // Pesquisa a característica do campo
          x_Tipo_Campo := "C"
          x_Masc_Campo := "@!"

          For nLocaliza = 1 to Len(aParametros)
              If aParametros[nLocaliza,01] == "[D]"
                 If Alltrim(Upper(U_P_CORTA(aParametros[nLocaliza,03], "|", 02))) == Alltrim(Upper(aListax[nContar,04]))
                    x_Tipo_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 06)
                    x_Masc_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 08)          
                    Exit
                 Endif
              Endif
          Next nLocaliza          

          // Inclui o parâmetro de quebra
          aAdd( aParametros, { "[Q]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|" + "51 - Courier New 10 - Negrito|50   |60   |" + x_Tipo_Campo + "|" + Strzero(nOrdenacao,5) + "|" + x_Masc_Campo + "|[F]" } )

          nSequencia += 1
          nCodigoLan += 1
          nOrdenacao += 10

       Endif   

   Next nContar    
       
   // Cria parâmetros de Totalizadores
   nSequencia := 1
   nCodigoLan := 1
   nOrdenacao := 1

   // Conta quantos campos totalizadores foram indicado. Somente no último parâmetro do totalizador que gravação a quantidade de salto de linhas
   QtdCamposT := 0
   For nContar = 1 to Len(aListax)
       If aListax[nContar,03] == "S"      
          QtdCamposT += 1
       Endif
   Next nContar        
   
   // Cria os parâmetros de totalizadores
   nTotCampo := 0

   For nContar = 1 to len(aListax)

       If aListax[nContar,03] == "S"

          // Pesquisa a característica do campo
          x_Tipo_Campo := "C"
          x_Masc_Campo := "@!"

          For nLocaliza = 1 to Len(aParametros)
              If aParametros[nLocaliza,01] == "[D]"
                 If Alltrim(Upper(U_P_CORTA(aParametros[nLocaliza,03], "|", 02))) == Alltrim(Upper(aListax[nContar,04]))
                    x_Colu_campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 04)
                    x_Tipo_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 06)
//                  x_Masc_Campo := U_P_CORTA(aParametros[nLocaliza,03], "|", 08)          
                    x_Masc_Campo := "@E 99999999999.99"
                    Exit
                 Endif
              Endif
          Next nLocaliza          

          nTotCampo += 1 

          If nTotCampo <> QtdCamposT
             nnSaldtoLin := 0
          Else
             nnSaldtoLin := 60             
          Endif
          
          aAdd( aParametros, { "[Z]", nSequencia, Strzero(nCodigoLan,6) + "|" + aListax[nContar,4] + "|" + "51 - Courier New 10 - Negrito|" + x_Colu_campo + "|" + Alltrim(Str(nnSaldtoLin)) + "|" + x_Tipo_Campo + "|" + Strzero(nOrdenacao,5) + "|" + x_Masc_Campo + "|[F]" } )

          nSequencia += 1
          nCodigoLan += 1
          nOrdenacao += 10

       Endif

   Next nContar    

   oDlgCFG1:End()
   
Return(.T.)   

// ##############################################
// Funçõ que gera a saída da pesquisa em Excel ##
// ##############################################
Static Function Geraexcel(_TipoChamada)

   // Verifica se o excel está instalado no equipamento
   If ! ApOleClient( 'MsExcel' )
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
	  Return(Nil)
   EndIf

   // Se chamado por ADMIN
   If _TipoChamada == 0
      // Consiste o título da quary
      If Empty(Alltrim(cPesquisa))
         MsgAlert("Título da consulta não informado.")
         Return(.T.)
      Endif
   
      // Consiste a informação do módulo
      If Substr(cComboBx2,01,02) == "00"
         MsgAlert("Módulo não selecionado.")
         Return(.T.)
      Endif
   Endif   

   // Verifica se existe resultado a ser listado
   If Len(aData) == 0
      MsgStop("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + " Nenhum resultado de consulta disponível para visualização em Excel.")
      Return(.T.)
   Endif
      
   // Envia para a função que gera o excel do resultado da pesquisa
   MsgRun("Favor Aguarde! Gerando Excel do resultado da pesquisa ...", "Gerando Excel de resultados",{|| xGeraexcel() })
   
Return

// ###################################################################
// Função que grava a indicação de impressão, grupo e totalizadores ##
// ###################################################################
Static Function xGeraexcel()

    Local cString      := ""
    Local xComando     := ""
    Local nContar      := 0
	Local oExcelApp
	Local oExcel
	Local cSpreadSheet := ""
	Local cTable       := ""
	Local cArq         := CriaTrab(Nil,.F.) + ".xml"
	Local cDirTmp      := GetTempPath()
    Local nColunas     := 0

	If ! ApOleClient( 'MsExcel' )
		MsgStop("MsExcel não instalado.")
		Return(Nil)
	EndIf

	oExcel := FWMSEXCEL():New()
	cSpreadSheet := Alltrim(cPesquisa)
	cTable       := Alltrim(cPesquisa)
	oExcel:AddworkSheet(cSpreadSheet)

	oExcel:AddTable (cSpreadSheet,cTable)

    // ############################
    // Cria o cabeçalho do excel ##
    // ############################
    For nContar := 1 to Len(aHead)
   	    oExcel:AddColumn(cSpreadSheet,cTable,aHead[nContar],1,1,.F.)
        nColunas += 1
    Next nContar                                       
    
    // ###############################
    // Imprime os dados da consulta ##
    // ###############################
	For nContar := 1 To Len(aData)

        // Carrega o conteúdo dos campos
        cString := "{"

        For nVezes = 1 to Len(aData[1])
            cString := cString + "'" + StrTran(StrTran(aData[nContar,nVezes], "'", ""), '"', "") + "',"
        Next nVezes    

        // Elimina a última vírgula        
        cString := Substr(cString,01, Len(Alltrim(cString))-1) + "}"
                                             
        // Executa o comando
  		oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

    Next nContar

    // ################################################
    // Imprime os parâmetros da pesquisa se houverem ##
    // ################################################
    If Len(aVerifica) == 0
    Else

       // Cria uma linha em branco
       cString := "{"
       For nContar := 1 to nColunas
           cString := cString + '"",'
       Next nContar
       
       // Elimina a última vírgula
       cString := Substr(cString,01, Len(Alltrim(cString))-1) + "}"
 	   oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

       // Cria a linha com a identificação de Parâmetros de Pesquisa
       cString := "{ 'PARÂMETROS DA PESQUISA',"
       For nContar := 1 to (nColunas - 1)
           cString := cString + '"",'
       Next nContar
       
       // Elimina a última vírgula
       cString := Substr(cString,01, Len(Alltrim(cString))-1) + "}"
 	   oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

       // Cria uma linha em branco
       cString := "{"
       For nContar := 1 to nColunas
           cString := cString + '"",'
       Next nContar
       
       // Elimina a última vírgula
       cString := Substr(cString,01, Len(Alltrim(cString))-1) + "}"
 	   oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

       // #########################################
       // Imprime os dados do Filtro da pesquisa ##
       // #########################################
       For ncontar = 1 to Len(aVerifica)
 
           // Elabora o comando a ser utilizado
           j := aVerifica[nContar,02]
           cEspacos := Replicate('"",', (nColunas - 2))
           cEspacos := Substr(cEspacos,01, Len(Alltrim(cEspacos)) - 1)
           cString := ""
           
           Do Case
              Case aVerifica[nContar,04] == "C"
                   cString := '{"' + Alltrim(StrTran(aVerifica[nContar,03], "?", ":")) + '","' + MV_PAR&J + '",' + cEspacos + '}'
              Case aVerifica[nContar,04] == "D"
                   cString := '{"' + Alltrim(StrTran(aVerifica[nContar,03], "?", ":")) + '","' + Dtoc(MV_PAR&J) + '",' + cEspacos + '}'
              Case aVerifica[nContar,04] == "N"
                   If aVerifica[nContar,06] == 0
                      cString := '{"' + Alltrim(StrTran(aVerifica[nContar,03], "?", ":")) + '","' + STRTRAN(STR(MV_PAR&J, aVerifica[nContar,05], aVerifica[nContar,06]), "@E" + Replicate("9", aVerifica[nContar,05])) + '",' + cEspacos + '}'
                   Else
                      cString := '{"' + Alltrim(StrTran(aVerifica[nContar,03], "?", ":")) + '","' + STRTRAN(STR(MV_PAR&J, aVerifica[nContar,05], aVerifica[nContar,06]), "@E" + Replicate("9", aVerifica[nContar,05]) + "." + Replicate("9", aVerifica[nContar,06])) + '",' + cEspacos + '}'
                   Endif
           EndCase                        
           
           // Executa o comando
           oExcel:AddRow(cSpreadSheet,cTable, &(cString) )

       Next nContar
    Endif   

    // ###################################
    // Cria o arquivo para visualização ##
    // ###################################
	cArq := CriaTrab( NIL, .F. ) + ".xml"
	cDirTmp := GetTempPath()

	oExcel:Activate()
	oExcel:GetXMLFile(cArq)

	If __CopyFile( cArq, cDirTmp + cArq )
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cDirTmp + cArq )
		oExcelApp:SetVisible(.T.)
	EndIf

Return(.T.)

// ###############################################################
//                                                              ##
// NÃO APAGAR ESTA FUNÇÃO ABAIXO. SERÁ USADA NA PRÓXIMA RELEASE ##
//                                                              ##
// ###############################################################

// ##################################################################################
// Função que permite o usuário alterar a parametrização dos detalhes do relatório ##
// ##################################################################################
Static Function AltDetalhes( __Campo)


   Local aComboBx1	 := {"Item01","Item02"}
   Local aComboBx2	 := {"Item01","Item02"}
   Local aComboBx3	 := {"Item01","Item02"}
   Local cComboBx1
   Local cComboBx2
   Local cComboBx3
   Local cGet1	 := Space(25)
   Local cGet2	 := Space(25)
   Local cGet3	 := Space(25)
   Local cGet4	 := Space(25)
   Local cGet5	 := Space(25)
   Local cGet6	 := Space(25)
   Local cGet7	 := Space(25)
   Local cGet8	 := Space(25)
   Local cGet9	 := Space(25)
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local lCheckBox1	 := .T.
   Local lCheckBox2	 := .T.
   Local lCheckBox3	 := .T.
   Local lCheckBox4	 := .T.
   Local lCheckBox5	 := .T.
   Local lCheckBox6	 := .T.
   Local oCheckBox1
   Local oCheckBox2
   Local oCheckBox3
   Local oCheckBox4
   Local oCheckBox5
   Local oCheckBox6
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oMemo2
   Local oMemo3

   Private oDlgDDD

   DEFINE MSDIALOG oDlgDDD TITLE "ADVPL Tools - Report Design" FROM C(178),C(181) TO C(625),C(512) PIXEL

   @ C(005),C(002) Jpeg FILE "advpltools.png" Size C(098),C(022) PIXEL NOBORDER OF oDlgDDD

   @ C(028),C(003) GET oMemo2 Var cMemo2 MEMO Size C(156),C(001) PIXEL OF oDlgDDD
   @ C(200),C(004) GET oMemo3 Var cMemo3 MEMO Size C(156),C(001) PIXEL OF oDlgDDD

   @ C(033),C(005) Say "Identificação"       Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(054),C(005) Say "Código"              Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(054),C(109) Say "Ordem de Impressão"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(075),C(005) Say "Campo/Conteúdo"      Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(096),C(005) Say "Fonte"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(109),C(081) Say "Máscara"             Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(117),C(005) Say "Tipo"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(117),C(053) Say "Tamanho"             Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(117),C(083) Say "Decimal"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(117),C(107) Say "Máscara"             Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(176),C(005) Say "Coluna de Impressão" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(176),C(068) Say "Salto de Linha"      Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
   @ C(176),C(113) Say "Tamanho da Linha"    Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgDDD
  
   @ C(042),C(005) MsGet    oGet6      Var   cGet6      Size C(155),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(064),C(005) MsGet    oGet1      Var   cGet1      Size C(022),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(064),C(109) MsGet    oGet4      Var   cGet4      Size C(026),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(084),C(005) ComboBox cComboBx1  Items aComboBx1  Size C(155),C(010)                                       PIXEL OF oDlgDDD
   @ C(104),C(005) ComboBox cComboBx2  Items aComboBx2  Size C(155),C(010)                                       PIXEL OF oDlgDDD
   @ C(127),C(005) ComboBox cComboBx3  Items aComboBx3  Size C(043),C(010)                                       PIXEL OF oDlgDDD
   @ C(127),C(053) MsGet    oGet7      Var   cGet7      Size C(024),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(127),C(083) MsGet    oGet8      Var   cGet8      Size C(013),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(127),C(107) MsGet    oGet9      Var   cGet9      Size C(052),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(142),C(005) CheckBox oCheckBox1 Var   lCheckBox1 Prompt "Imprime Campo / Conteúdo"     Size C(076),C(008) PIXEL OF oDlgDDD
   @ C(142),C(107) CheckBox oCheckBox4 Var   lCheckBox4 Prompt "Campo Totalizador"            Size C(055),C(008) PIXEL OF oDlgDDD
   @ C(152),C(005) CheckBox oCheckBox2 Var   lCheckBox2 Prompt "Lista Campo no Detalhe"       Size C(067),C(008) PIXEL OF oDlgDDD
   @ C(152),C(116) CheckBox oCheckBox5 Var   lCheckBox5 Prompt "Somatório"                    Size C(034),C(008) PIXEL OF oDlgDDD
   @ C(163),C(005) CheckBox oCheckBox3 Var   lCheckBox3 Prompt "Campo de Quebra de Relatório" Size C(086),C(008) PIXEL OF oDlgDDD
   @ C(163),C(116) CheckBox oCheckBox6 Var   lCheckBox6 Prompt "Quantos"                      Size C(033),C(008) PIXEL OF oDlgDDD
   @ C(186),C(005) MsGet    oGet2      Var   cGet2      Size C(026),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(186),C(068) MsGet    oGet3      Var   cGet3      Size C(026),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD
   @ C(186),C(113) MsGet    oGet5      Var   cGet5      Size C(026),C(009) COLOR CLR_BLACK    Picture "@!"       PIXEL OF oDlgDDD

   @ C(205),C(043) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgDDD
   @ C(205),C(083) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDDD ACTION( oDlgDDD:End() )

   ACTIVATE MSDIALOG oDlgDDD CENTERED 

Return(.T.)
