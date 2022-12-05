#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM522.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 29/12/2016                                                              ##
// Objetivo..: Gatilho que verifica se o cliente selecionado está com seu cadastro     ##
//             completo. Se não estiver, não permite utilizá-lo.                       ##
// ######################################################################################
User Function AUTOM522(_Codigo, _Loja)

   Local xPessoa   := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_PESSOA")
   Local xNreduz   := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_NREDUZ")
   Local xEnd      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_END")   
   Local xTipo     := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_TIPO")   
   Local xEst      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_EST")      
   Local xCod_Mun  := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_COD_MUN")      
   Local xBairro   := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_BAIRRO")      
   Local xCep      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_CEP")         
   Local xDDD      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_DDD")            
   Local xTel      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_TEL")            
   Local xCGC      := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_CGC")            
   Local xinscr    := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_INSCR")            
   Local xEmail    := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_EMAIL")               
   Local xNatureza := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_NATUREZ")               
   Local xGrptrib  := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_GRPTRIB")               
   Local xCodPais  := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_CODPAIS")               
   Local xContrib  := Posicione("SA1", 1, xFilial("SA1") + _Codigo + _Loja, "A1_CONTRIB")                  

   Local lErro     := .F.

   U_AUTOM628("AUTOM522")

   If Empty(Alltrim(_Codigo))
      M->C5_CLIENT  := Space(06)
      M->C5_LOJAENT := Space(03)
      M->C5_NOMCL   := Space(60)
      Return(.T.)
   Endif

   If Empty(Alltrim(_Loja))
      M->C5_CLIENT  := Space(06)
      M->C5_LOJAENT := Space(03)
      M->C5_NOMCL   := Space(60)
      Return(.T.)
   Endif

   If Empty(Alltrim(xPessoa))
      lErro := .T.
   Endif

   If Empty(Alltrim(xNreduz))
      lErro := .T.
   Endif

   If Empty(Alltrim(xEnd))
      lErro := .T.
   Endif

   If Empty(Alltrim(xTipo))
      lErro := .T.
   Endif

   If Empty(Alltrim(xEst))
      lErro := .T.
   Endif

   If Empty(Alltrim(xCod_Mun))
      lErro := .T.
   Endif

   If Empty(Alltrim(xBairro))
      lErro := .T.
   Endif

   If Empty(Alltrim(xCep))
      lErro := .T.
   Endif

   If Empty(Alltrim(xDDD))
      lErro := .T.
   Endif

   If Empty(Alltrim(xTel))
      lErro := .T.
   Endif

   If Empty(Alltrim(xCGC))
      lErro := .T.
   Endif

   If Empty(Alltrim(xinscr))
      lErro := .T.
   Endif

   If Empty(Alltrim(xEmail))
      lErro := .T.
   Endif

   If Empty(Alltrim(xNatureza))
      lErro := .T.
   Endif

   If Empty(Alltrim(xGrptrib))
      lErro := .T.
   Endif

   If Empty(Alltrim(xCodPais))
      lErro := .T.
   Endif

   If Empty(Alltrim(xContrib))
      lErro := .T.
   Endif

   If lErro == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O Cliente selecionado possui dados incompletos em seu seu cadastro. Utilização deste não será permitido até que o cadastro esteja completamente atualizado. Verifique!")
      M->C5_CLIENTE := Space(06)
      M->C5_LOJACLI := Space(03)
      M->C5_CLIENT  := Space(06)
      M->C5_LOJAENT := Space(03)
      M->C5_NOMCL   := Space(60)
   Endif
   
Return(_Loja)