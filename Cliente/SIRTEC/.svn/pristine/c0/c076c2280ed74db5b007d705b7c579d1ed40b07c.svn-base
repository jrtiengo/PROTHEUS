#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #######################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                     ##
// ------------------------------------------------------------------------------------ ##
// Referencia: SOLTPAR00.PRW                                                            ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 25/06/2019                                                               ##
// Objetivo..: Programa uqe chama os programas dos parametrizadores de importação de OS ##
// #######################################################################################

User Function SOLTPAR00()

   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Importação OS (GPM)" FROM C(178),C(181) TO C(354),C(441) PIXEL

   @ C(002),C(005) Button "GPM - Parametros Criação OS"         Size C(121),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR01() )
   @ C(018),C(005) Button "GPM - Parametrios Tipo de Serviço"   Size C(121),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR30() )
   @ C(034),C(005) Button "GPM - Parametros Itens Atendimento"  Size C(121),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR13() )
   @ C(050),C(005) Button "GPM - Parametros Atendimento Equipe" Size C(121),C(015) PIXEL OF oDlg ACTION( U_SOLTPAR24() )
   @ C(066),C(005) Button "Retornar"                            Size C(121),C(015) PIXEL OF oDlg ACTION( oDlg:End()    )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
