#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR36.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 02/07/2019                                                             ##
// Objetivo..: Programa de permite o usuário a informar email que receberão aviso de  ##
//             inconsistências pelo processo de Importação de OS - GPM.               ##
// #####################################################################################

User Function SOLTPAR76()                                                                         

   Private cEmail	 := sPACE(250)
   Private oGet1

   Private oDlg
                      
   // Verifica se a variável SIR_EMLLOG existe. Se não existir, será criada.   
   DbSelectArea("SX6") 
   If !DbSeek(xFilial("SX6") + "SIR_EMLLOG") 
      RecLock("SX6",.T.)
      replace X6_VAR     with "SIR_EMLLOG"
      replace X6_TIPO    with "C" 
      replace X6_DESCRIC with "Emails recebimento inconsistencia GPM"
      replace X6_DSCSPA  with "Emails recebimento inconsistencia GPM"
      replace X6_DSCENG  with "Emails recebimento inconsistencia GPM"
      MsUnLock()        
   Else
      cEmail := Alltrim(SX6->X6_CONTEUD) + Space(250 - Len(Alltrim(SX6->X6_CONTEUD)))
   Endif                                                                             

   DEFINE MSDIALOG oDlg TITLE "Importação de OS - GPM" FROM C(178),C(181) TO C(287),C(943) PIXEL

   @ C(002),C(005) Say "Informe abaixo os emails dos usuários que receberão aviso via email de eventuais inconsistências encontradas no momento da Importação dos arquivos Json." Size C(372),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(011),C(005) Say "Os emails deverão ser informados separados por Ponto e Vírgula (;)" Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlg 

   @ C(021),C(005) MsGet oGet1 Var cEmail Size C(372),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(036),C(172) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( FechaEmailSX6() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                                                                               
                              
// Função que grava o conteúdo da variável e fecha o programa
Static Function FechaEmailSX6()

   DbSelectArea("SX6") 
   If DbSeek(xFilial("SX6") + "SIR_EMLLOG") 
      RecLock("SX6",.F.)
      replace X6_CONTEUD  with cEmail
      MsUnLock()        
   Endif
           
   oDlg:End()

Return(.T.)