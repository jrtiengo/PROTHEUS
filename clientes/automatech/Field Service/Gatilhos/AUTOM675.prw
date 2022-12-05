#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM675.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 08/02/2018                                                               ##
// Objetivo..: Gatilho que pesquisa o nome do cliente e popula o campo Nome  do Cliente ##
//             na tela da Ordem de Serviço. Este gatilho é disparado logo após a infor- ##
//             maçao do número da nota fiscal de entrada ou seleção na tela do OS.      ##
// Parâmetros: Sem parâmetros                                                           ##
// #######################################################################################

User Function AUTOM675()                    

   If Empty(Alltrim(M->AB6_NFENT))   
      M->AB6_NFENT  := Space(12)
      M->AB6_CODCLI := Space(06)
      M->AB6_LOJA   := Space(03)
      M->AB6_NCLIE  := Space(40)
      M->AB6_CONPAG := Space(03)
      M->AB6_TABELA := Space(03)
      Return(.T.)
   Endif   

   // ######################################################################################################
   // Pesquisa o código e loja do fornecedor pela leitura da nota fiscal de entrada informada/selecionada ##
   // ######################################################################################################
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := "SELECT SF1.F1_FORNECE,"
   cSql += "       SF1.F1_LOJA   ,"
   cSql += "       SA2.A2_CGC    ,"
   cSql += "       SA1.A1_COD    ,"
   cSql += "       SA1.A1_LOJA   ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_COND    "  
   cSql += "  FROM " + RetSqlName("SF1") + " SF1, "
   cSql += "       " + RetSqlName("SA2") + " SA2, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SF1.F1_FILIAL  = '" + Alltrim(cFilAnt)      + "'"
   cSql += "   AND SF1.F1_DOC     = '" + Alltrim(M->AB6_NFENT) + "'"
   cSql += "   AND SF1.D_E_L_E_T_ = ''"
   cSql += "   AND SA2.A2_COD     = SF1.F1_FORNECE"
   cSql += "   AND SA2.A2_LOJA    = SF1.F1_LOJA   "
   cSql += "   AND SA2.D_E_L_E_T_ = ''            "
   cSql += "   AND SA1.A1_CGC     = SA2.A2_CGC    "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      MsgAlert("Atenção! Documento informado não localizado. Verifique!")
      M->AB6_NFENT  := Space(12)
      M->AB6_CODCLI := Space(06)
      M->AB6_LOJA   := Space(03)
      M->AB6_NCLIE  := Space(40)
      M->AB6_CONPAG := Space(03)
      M->AB6_TABELA := Space(03)
      Return(.T.)
   Endif

   // ################################################################
   // Pesquisa o cliente pela leitura da tabela SA1 pelo campo CNPJ ##
   // ################################################################
   M->AB6_CODCLI := T_FORNECEDOR->A1_COD
   M->AB6_LOJA   := T_FORNECEDOR->A1_LOJA
   M->AB6_NCLIE  := T_FORNECEDOR->A1_NOME
   M->AB6_CONPAG := T_FORNECEDOR->A1_COND
   M->AB6_TABELA := U_AUTOM121(3, M->AB6_CODCLI, M->AB6_LOJA)                                                                                              

Return(.T.)