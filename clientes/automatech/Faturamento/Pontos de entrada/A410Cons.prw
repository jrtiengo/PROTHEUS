#include "topconn.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "COLORS.ch"

//F�BIO ANDR� MICHELON - MICROSIGA SERRA GA�CHA - 22/05/2007
//OBJETIVO:	INCLUIR BOT�O DE ORDEM DE PRODU��O NA TELA DE PEDIDO DE VENDA

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function A410Cons()

   Local  _aBotoes    := {}
   Public oOrigGetDad := {}

   U_AUTOM628("A410CONS")

   AADD( _aBotoes, { "DBG07", {||U_AUTOM248() }, "Mais >>>", "Mais >>>" } )

Return _aBotoes