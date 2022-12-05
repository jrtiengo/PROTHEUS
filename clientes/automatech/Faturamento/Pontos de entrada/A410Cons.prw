#include "topconn.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "COLORS.ch"

//FÁBIO ANDRÉ MICHELON - MICROSIGA SERRA GAÚCHA - 22/05/2007
//OBJETIVO:	INCLUIR BOTÃO DE ORDEM DE PRODUÇÃO NA TELA DE PEDIDO DE VENDA

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function A410Cons()

   Local  _aBotoes    := {}
   Public oOrigGetDad := {}

   U_AUTOM628("A410CONS")

   AADD( _aBotoes, { "DBG07", {||U_AUTOM248() }, "Mais >>>", "Mais >>>" } )

Return _aBotoes