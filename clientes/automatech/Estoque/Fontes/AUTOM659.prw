#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#include "TOTVS.CH"
#include "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#Include "Tbiconn.Ch"

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   018                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  008                                                // Máximo de caracteres por linha de valores numéricos

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM659.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 24/11/2017                                                           ##
// Objetivo..: Grava o pedido de venda pelo processo automático                     ##
// ###################################################################################

User Function AUTOM659(kFilial, kPedido)
 
   Local cSql    := ""
   Local aCabec  := {}
   Local aItens  := {}
   Local aLinha  := {}
   Local nContar := 0
   Local nX      := 0
   Local nY      := 0
   Local cDoc    := ""
   Local lOk     := .T.
 
   PRIVATE lMsErroAuto := .F.

   // ##############################
   // Posiciona o pedido de venda ##
   // ##############################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := "SELECT C5_FILIAL ,"
   cSql += "       C5_NUM    ,"
   cSql += "       C5_TIPO   ,"
   cSql += "       C5_CLIENTE,"
   cSql += "       C5_LOJACLI,"
   cSql += "       C5_CLIENT ,"
   cSql += "       C5_LOJAENT "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL  = '" + Alltrim(kFilial) + "'"
   cSql += "   AND C5_NUM     = '" + Alltrim(kPedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )
      
   // ##########################################
   // Pesquisa os produtos do pedido de venda ##
   // ##########################################



   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( kFilial + kPedido )

      aCabec := {}
      aItens := {}
      aadd(aCabec,{"C5_NUM"    ,cDoc,Nil})
      aadd(aCabec,{"C5_TIPO"   ,"N",Nil})
      aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
      aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
      aadd(aCabec,{"C5_CLIENT" ,SA1->A1_COD,Nil})
      aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})

      For nX := 1 To 30
          aLinha := {}
          aadd(aLinha,{"C6_ITEM"   ,SB1->B1_COD,Nil})   
          aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})
          aadd(aLinha,{"C6_QTDVEN" ,2,Nil})
          aadd(aLinha,{"C6_PRCVEN" ,100,Nil})
          aadd(aLinha,{"C6_PRUNIT" ,100,Nil})
          aadd(aLinha,{"C6_VALOR"  ,200,Nil})
          aadd(aLinha,{"C6_TES"    ,"501",Nil})
          aadd(aItens,aLinha)
      Next nX

      ConOut(PadC("Teste de alteracao",80))
      ConOut("Inicio: "+Time())
      MATA410(aCabec,aItens,4)
      ConOut("Fim  : "+Time())
      ConOut(Repl("-",80))   







   //****************************************************************
   //* Verificacao do ambiente para teste
   //****************************************************************
   dbSelectArea("SB1")
   dbSetOrder(1)
   If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
      lOk := .F.
      ConOut("Cadastrar produto: PA001")
   EndIf

   dbSelectArea("SF4")
   dbSetOrder(1)

   If !SF4->(MsSeek(xFilial("SF4")+"501"))
      lOk := .F.
      ConOut("Cadastrar TES: 501")
   EndIf

   dbSelectArea("SE4")
   dbSetOrder(1)
   If !SE4->(MsSeek(xFilial("SE4")+"001"))
      lOk := .F.
      ConOut("Cadastrar condicao de pagamento: 001")
   EndIf
   
   If !SB1->(MsSeek(xFilial("SB1")+"PA002"))
      lOk := .F.
      ConOut("Cadastrar produto: PA002")
   EndIf

   dbSelectArea("SA1")
   dbSetOrder(1)
   If !SA1->(MsSeek(xFilial("SA1")+"CL000101"))
      lOk := .F.
      ConOut("Cadastrar cliente: CL000101")
   EndIf

   If lOk
   
      //****************************************************************
      //* Teste de alteracao                                     
      //****************************************************************
      aCabec := {}
      aItens := {}
      aadd(aCabec,{"C5_NUM",cDoc,Nil})
      aadd(aCabec,{"C5_TIPO","N",Nil})
      aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
      aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
      aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
      aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
      If cPaisLoc == "PTG"
         aadd(aCabec,{"C5_DECLEXP","TESTE",Nil})
      Endif
      For nX := 1 To 30
          aLinha := {}
          aadd(aLinha,{"LINPOS","C6_ITEM",StrZero(nX,2)})
          aadd(aLinha,{"AUTDELETA","N",Nil})
          aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})
          aadd(aLinha,{"C6_QTDVEN",2,Nil})
          aadd(aLinha,{"C6_PRCVEN",100,Nil})
          aadd(aLinha,{"C6_PRUNIT",100,Nil})
          aadd(aLinha,{"C6_VALOR",200,Nil})
          aadd(aLinha,{"C6_TES","501",Nil})
          aadd(aItens,aLinha)
      Next nX
      ConOut(PadC("Teste de alteracao",80))
      ConOut("Inicio: "+Time())
      MATA410(aCabec,aItens,4)
      ConOut("Fim  : "+Time())
      ConOut(Repl("-",80))   
 
   EndIf

   RESET ENVIRONMENT

Return(.T.)