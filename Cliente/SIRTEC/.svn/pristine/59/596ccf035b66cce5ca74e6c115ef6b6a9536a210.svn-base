#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch'    //Informa a biblioteca

// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTPAR35.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 28/06/2019                                                             ##
// Objetivo..: Programa de manutenção dos parâmetros de Importação de OS - GPM        ##
// #####################################################################################

User Function SOLTPAR67()

   Private cOrigem   := ""
   Private cDestino  := ""
   Private cArqEmail := ""
   
   Private oGet1
   Private oGet2

   Private oDlg

   // Verifica se a variável SIR_AIMP existe. Se não existir, será criada.   
   DbSelectArea("SX6") 
   If !DbSeek(xFilial("SX6") + "SIR_AIMP") 
      RecLock("SX6",.T.)
      replace X6_VAR     with "SIR_AIMP"
      replace X6_TIPO    with "C" 
      replace X6_DESCRIC with "Pasta de Arquivos para Importação GPM."
      replace X6_DSCSPA  with "Pasta de Arquivos para Importação GPM."
      replace X6_DSCENG  with "Pasta de Arquivos para Importação GPM."
      MsUnLock()        
      cOrigem := Space(250)
   Else
      cOrigem  := SX6->X6_CONTEUD
      cOrigem  := Alltrim(cOrigem)  + Space(250 - Len(Alltrim(cOrigem)))
   Endif                                                                             

   // Verifica se a variável SIR_IMPO existe. Se não existir, será criada.   
   DbSelectArea("SX6") 
   If !DbSeek(xFilial("SX6") + "SIR_IMPO") 
      RecLock("SX6",.T.)
      replace X6_VAR     with "SIR_IMPO"
      replace X6_TIPO    with "C" 
      replace X6_DESCRIC with "Pasta de Arquivos Importados GPM."
      replace X6_DSCSPA  with "Pasta de Arquivos Importados GPM."
      replace X6_DSCENG  with "Pasta de Arquivos Importados GPM."
      MsUnLock()        
      cDestino := Space(250)
   Else
      cDestino := SX6->X6_CONTEUD
      cDestino := Alltrim(cDestino) + Space(250 - Len(Alltrim(cDestino)))
   Endif                                                                             

   // Verifica se a variável SIR_PEMAL existe. Se não existir, será criada.   
   DbSelectArea("SX6") 
   If !DbSeek(xFilial("SX6") + "SIR_PEMAL") 
      RecLock("SX6",.T.)
      replace X6_VAR     with "SIR_PEMAL"
      replace X6_TIPO    with "C" 
      replace X6_DESCRIC with "Pasta Arquivos Inconsistênia Importação GPM."
      replace X6_DSCSPA  with "Pasta Arquivos Inconsistênia Importação GPM."
      replace X6_DSCENG  with "Pasta Arquivos Inconsistênia Importação GPM."
      MsUnLock()        
      cArqEmail := Space(250)
   Else                                                                  
      cArqEmail := SX6->X6_CONTEUD
      cArqEmail := Alltrim(cArqEmail) + Space(250 - Len(Alltrim(cArqEmail)))
   Endif                                                                             

   DEFINE MSDIALOG oDlg TITLE "Parâmetros de importação de OS - GPM" FROM C(176),C(170) TO C(367),C(788) PIXEL

   @ C(005),C(005) Say "Pasta de Origem dos arquivos de importação de OS GPM"                              Size C(147),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(005) Say "Pasta de Destino dos arquivos importados de OS - GPM"                              Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(051),C(005) Say "Pasta de gravação de arquivo de Log de inconsistências a serem enviados por Email" Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cOrigem   Size C(300),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(038),C(005) MsGet oGet2 Var cDestino  Size C(300),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(061),C(005) MsGet oGet3 Var cArqEmail Size C(300),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(076),C(137) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaParImpo() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                          

// Função que grava o conteúdo dos parâmetros na SX6
Static Function SalvaParImpo()

   // Grava o conteúdo de Origem
   DbSelectArea("SX6") 
   If DbSeek(xFilial("SX6") + "SIR_AIMP") 
      RecLock("SX6",.F.) 
      replace X6_CONTEUD with Alltrim(cOrigem)
      replace X6_CONTENG with Alltrim(cOrigem)
      replace X6_CONTSPA with Alltrim(cOrigem)
      MsUnLock()        
   Endif

   // Grava o conteúdo de Destino
   DbSelectArea("SX6") 
   If DbSeek(xFilial("SX6") + "SIR_IMPO") 
      RecLock("SX6",.F.) 
      replace X6_CONTEUD with Alltrim(cDestino)
      replace X6_CONTENG with Alltrim(cDestino)
      replace X6_CONTSPA with Alltrim(cDestino)
      MsUnLock()        
   Endif                              
   
   // Grava o conteúdo da pasta de envio de email
   DbSelectArea("SX6") 
   If DbSeek(xFilial("SX6") + "SIR_PEMAL") 
      RecLock("SX6",.F.) 
      replace X6_CONTEUD with Alltrim(cArqEmail)
      replace X6_CONTENG with Alltrim(cArqEmail)
      replace X6_CONTSPA with Alltrim(cArqEmail)
      MsUnLock()        
   Endif                              

   Odlg:End()
   
Return(.T.)