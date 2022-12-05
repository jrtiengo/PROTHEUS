#INCLUDE "protheus.ch"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: PE_FO10FILT.PRW                                                      ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Michel Aoki                                                          ##
// Data......: 22/10/2014                                                           ##
// Objetivo..: Filtro para não mostrar os títulos, pedidos e notas  na  consulta de ##
//             Clientes.                                                            ##
//             Para desativar, alterar AU_FILCLI                                    ##
// Parâmetros: Sem Parâmetros                                                       ##
// ##################################################################################
User Function FO10FILT()

   Local _cQuery := ""

   _cQuery += u_AutFilCli("  E1_FILIAL = 'ZZ'  And ")

Return(_cQuery)

// ####################
// Função FO10FLTR() ##
// ####################
User Function FO10FLTR()

   Local _cQuery := ""//Paramixb[]
   Local _lAtvFil := Alltrim(Getmv("AU_FILCLI")) == "S"

   _cQuery += u_AutFilCli(" E1_FILIAL = 'ZZ' And ")

Return(_cQuery)

// ####################
// Função F010FLPD() ##
// ####################
User Function F010FLPD()

   Local _cQuery := ""//Paramixb[]

   _cQuery += u_AutFilCli(" C5_FILIAL = 'ZZ'   And ")

Return(_cQuery)

// ####################
// Função FO10FLFT() ##
// ####################
User Function FO10FLFT()

   Local _cQuery := ""//Paramixb[]

   _cQuery += u_AutFilCli(" F2_FILIAL = 'ZZ'   And ")

Return(_cQuery)

// #############################
// Função AutFilCli(_cFilPar) ##
// #############################
USer Function AutFilCli(_cFilPar)

   Local _cQuery   := ""//Paramixb[]
   Local _lAtvFil  := Alltrim(Getmv("AU_FILCLI")) == "S"
   Local _cCodUser := RetCodUsr()      
   Local _aArea    := GetArea()
   Local _aAreaSA3 := SA3->(GetArea())

   If _lAtvFil
	  DbSelectArea("SA3")
	  DbSetorder(7)
	  If DbSeek(xFilial("SA3")+_cCodUser)
		 If SA3->A3_TSTAT <> "2"
			If !(SA1->A1_VEND == SA3->A3_COD .Or. SA1->A1_ZVEND2 == SA3->A3_COD)
			   _cQuery += _cFilPar
			EndIf
	     EndIf
	  EndIF
   EndIf

   RestArea(_aArea)
   RestArea(_aAreaSA3)

Return(_cQuery)