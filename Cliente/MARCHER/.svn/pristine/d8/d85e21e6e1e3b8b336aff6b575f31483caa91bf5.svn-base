#include "rwmake.ch"
/*/{Protheus.doc} MA330CP
Ponto de Entrada que define as partes do Custo
@type Ponto de Entrada
@ Projeto QUANTUM 1.0 Marcher
@author César Mussi
@since 26/01/2021
@return Array, retorna o Array com as Regras
/*/
User Function MA330CP ()
	LOCAL aRegraCP:={}
    //Materia Prima
	AADD(aRegraCP,"SB1->B1_TIPO $ 'MP/PA/PI/MC/AI/AP/EM/GG/ME/MS/SU' " )
    //GGF Direto
	AADD(aRegraCP,"SB1->B1_TIPO == 'MD' ")
    //GGF Indireto
	AADD(aRegraCP,"SB1->B1_TIPO == 'MI' ")

Return aRegraCP
