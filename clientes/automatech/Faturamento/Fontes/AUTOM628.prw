#INCLUDE "protheus.ch"  
#INCLUDE "PRTOPDEF.CH"


// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM628.PRW                                                          ##
// Par�metros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho                                             ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                               ##
// Data......: 12/09/2017                                                            ##
// Objetivo..: Programa que contabiliza a quantidade de acessos por programa/usu�rio ##
// Par�metros: PROGRAMA = Nome do programa a ser contabilizado                       ##
// #################################################################################### 

User Function AUTOM628(kPrograma)

// Local cSql      := ""
   Local cPrograma := Alltrim(kPrograma) + Space(20 - Len(Alltrim(kPrograma)))
   Local kUsuario  := Alltrim(cUserName) + Space(20 - Len(Alltrim(cUserName)))

   Return(.T.)

   // ####################################################
   // Pesquisa se o programa/usu�rio j� est� cadastrado ##
   // ####################################################
   DbSelectArea("ZPI")
   DbSetOrder(1)
   If DbSeek( xFilial("ZPI") + cPrograma + kUsuario)
      RecLock("ZPI",.F.)
      ZPI->ZPI_QTDA := ZPI->ZPI_QTDA + 1
	  MsUnlock()
   Else
      dbSelectArea("ZPI")
      RecLock("ZPI",.T.)
	  ZPI->ZPI_PROG := kPrograma
      ZPI->ZPI_USUA := cUserName
      ZPI->ZPI_QTDA := 1
	  MsUnlock()
   Endif

Return(.T.)