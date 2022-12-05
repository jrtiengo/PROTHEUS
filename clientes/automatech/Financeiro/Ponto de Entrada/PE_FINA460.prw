#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: PE_FINA460.PRW                                                          ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: ( ) Programa  (X) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Cesar Mussi                                                             ##
// Data......: 11/02/2014                                                              ##
// Objetivo..: Grava nos titulos gerados epla liquidacao os campos do array criado no  ##
//             PE F460SE1                                                              ##
// Parâmetros: Sem Parâmetros                                                          ##
// ######################################################################################

User Function F460Val()

   Local aAlias	:= GetArea()
   Local aRetorno	:= PARAMIXB
   Local cCampo
   Local cConteudo

   For nXX := 1 to Len( aRetorno )
       RecLock( "SE1" , .F. )
	   cCampo		:= aRetorno[ nXX , 1 ]
	   cConteudo	:= aRetorno[ nXX , 2 ]
	   &(cCampo)	:= cConteudo
	   SE1->( MsUnLock() )
   Next nXX

   RestArea( aAlias )

Return .T.

// ######################################################################
// Função que carrega um array com campos a serem replicados na Liquid ##
// ######################################################################
User Function F460SE1()

   Local aRetorno  := {}
   Local aArea     := GetArea()
   Local aAreaSE1  := GetArea("SE1")
   Local cLiquid   := ""

   // ################################################################
   // PONTO DE ENTRADA F460SE1                                      ##
   // Neste ponto de entrada dever  se retornar um array com os da- ##
   // dos de campo e conte£do  com dados dos titulos geradores a    ##
   // serem gravados de forma complementar nos titulos gerados ap¢s ##
   // a liquidacao.                                                 ##
   // ------------------------------------------------------------- ##
   // aComplem :=	ExecBlock("F460SE1",.f.,.f.,aComplem)           ##
   // Esta posicionado no titulo original, pode gravar o numero  da ##
   // liquidacao cLiquid.                                           ##
   // ################################################################
   Reclock("SE1",.f.)
   E1_HIST := ALLTRIM(E1_HIST) + "|Lq" + cLiquid
   MsUnlock()

   aAdd( aRetorno , { "SE1->E1_VEND1"  ,	SE1->E1_VEND1	 })
   aAdd( aRetorno , { "SE1->E1_VEND2"  ,	SE1->E1_VEND2	 })
   aAdd( aRetorno , { "SE1->E1_VEND3"  ,	SE1->E1_VEND3	 })
   aAdd( aRetorno , { "SE1->E1_VEND4"  ,	SE1->E1_VEND4	 })
   aAdd( aRetorno , { "SE1->E1_VEND5"  ,	SE1->E1_VEND5	 })
   aAdd( aRetorno , { "SE1->E1_COMIS1"  ,	SE1->E1_COMIS1	 })
   aAdd( aRetorno , { "SE1->E1_COMIS2"  ,	SE1->E1_COMIS2	 })
   aAdd( aRetorno , { "SE1->E1_COMIS3"  ,	SE1->E1_COMIS3	 })
   aAdd( aRetorno , { "SE1->E1_COMIS4"  ,	SE1->E1_COMIS4	 })
   aAdd( aRetorno , { "SE1->E1_COMIS5"  ,	SE1->E1_COMIS5	 })
   aAdd( aRetorno , { "SE1->E1_BASCOM1"  ,	SE1->E1_BASCOM1	 })
   aAdd( aRetorno , { "SE1->E1_BASCOM2"  ,	SE1->E1_BASCOM2	 })
   aAdd( aRetorno , { "SE1->E1_BASCOM3"  ,	SE1->E1_BASCOM3  })
   aAdd( aRetorno , { "SE1->E1_BASCOM4"  ,	SE1->E1_BASCOM4  })
   aAdd( aRetorno , { "SE1->E1_BASCOM5"  ,	SE1->E1_BASCOM5  })
   aAdd( aRetorno , { "SE1->E1_VALCOM1"  ,	SE1->E1_VALCOM1  })
   aAdd( aRetorno , { "SE1->E1_VALCOM2"  ,	SE1->E1_VALCOM2  })
   aAdd( aRetorno , { "SE1->E1_VALCOM3"  ,	SE1->E1_VALCOM3  })
   aAdd( aRetorno , { "SE1->E1_VALCOM4"  ,	SE1->E1_VALCOM4  })
   aAdd( aRetorno , { "SE1->E1_VALCOM5"  ,	SE1->E1_VALCOM5  })
   aAdd( aRetorno , { "SE1->E1_PEDIDO"  ,	SE1->E1_PEDIDO	 })
   RestArea(aArea)
   RestArea(aAreaSE1)

Return(aRetorno)