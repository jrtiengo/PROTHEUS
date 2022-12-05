#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: PE_MT450FIM.PRW                                                     ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Jean Rehermann                                                      ##
// Data......: 26/09/2011                                                          ##
// Objetivo..: Tratamento dos Status dos PVs                                       ##
//             Tratamento do uso de Cartao de Credito no Faturamento               ##
//                                                                                 ##
//             Ponto de entrada MT450FIM - Liberação de crédito                    ##
//             Ponto de entrada no final da liberação manual de crédito            ##
// ##################################################################################

User Function incluiop()

		aColsC2 :={}
		aAdd(aColsC2,{"C2_NUM"		, "055688"			,NIL})
		aAdd(aColsC2,{"C2_ITEM"		, "01"			,NIL})
		aAdd(aColsC2,{"C2_SEQUEN"	, "001"			,NIL})
		aAdd(aColsC2,{"C2_QUANT"	, 10		        ,NIL})
		aAdd(aColsC2,{"C2_QUJE"		, 0					,NIL})
		aAdd(aColsC2,{"C2_PRODUTO"	, "03037328920000001"	,NIL})
		aAdd(aColsC2,{"C2_DATPRF"	, dDataBase, NIL})
		aAdd(aColsC2,{"C2_DATPRI"	, dDataBase			,NIL})
		aAdd(aColsC2,{"C2_UM"		, "RL"		,NIL})
		aAdd(aColsC2,{"C2_TPOP"		, "F"				,NIL})
		aAdd(aColsC2,{"C2_OBS"		, "TESTE DO HARALD",NIL})
		aAdd(aColsC2,{"C2_DESTINA"	, "P"				,NIL})
		aAdd(aColsC2,{"C2_SEQPAI"	, "000"				,NIL})
		aAdd(aColsC2,{"C2_ZDOE"   	, dDataBase, NIL})
		aAdd(aColsC2,{"AUTEXPLODE"  , "S"				,NIL})
				
		lMSErroAuto := .F.
		MSExecAuto({|x,y| Mata650(x,y)},aColsC2,3)

        // ###############################################
		// MSExecAuto({|x,y| Mata650(x,y)},_aOrdProd,3) ##
		// ###############################################
		If lMSErroAuto
		   Mostraerro()
		   DisarmTransaction()
		   lImprime 	:= .f.
		   lContinua 	:= .f.
		Endif
				