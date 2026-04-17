
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
/*
// =====================================================================================================================================
// Ponto de entrada referente ao Portal XML - Geração de pré-nota
// Valida se o Documento foi gerado pelo ExecAuto - TOTVS
// ====================================================================================================================================
*/
User Function MT140SAI()
 
If FwIsInCallStack('U_Portal_XML') .or. FwIsInCallStack('U_SCHEDFILE') .OR. FwIsInCallStack('U_ExecTeste') .OR. ;
FwIsInCallStack('U_SCHEDNFE') .or.  FwIsInCallStack('U_SCHEDNSU') .or.  FwIsInCallStack('U_SCHEDCTE') .or. FwIsInCallStack('U_SCHEDMail')  ;
.OR. FwIsInCallStack("U_ALMOX") .OR. FwIsInCallStack('U_xNoraNfse')
      If ExistBlock("EZMT140SAI") 
           u_EZMT140SAI()
      Endif 
Endif
Return .t. 
