#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"   

User Function TESTEJSON()

   local cUrl       := 'http://numbersapi.com/random/trivia&#8221;
   local cGetParms  := ''
   local nTimeOut   := 200
   local aHeadStr   := {'Content-Type: application/json'}
   local cHeaderGet := ''
   local cRetorno   := ''
   local oObjJson   := nil

   cRetorno := HttpGet( cUrl , cGetParms, nTimeOut, aHeadStr, @cHeaderGet )

   If !FWJsonDeserialize(cRetorno,@oObjJson)
      MsgStop('Ocorreu erro no processamento do Json')
      Returnnil
   endif

   Msginfo( 'O valor ' + oObjJson:type + ' para o numero ' + Alltrim(Str(oObjJson:number)) + ' equivale: ' + oObjJson:text )

Return nil