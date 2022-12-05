#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function CRM980MDef()

   Local aRotina := {}
   
   //----------------------------------------------------------------------------------------------------------
   // [n][1] - Nome da Funcionalidade
   // [n][2] - Fun��o de Usu�rio
   // [n][3] - Opera��o (1-Pesquisa; 2-Visualiza��o; 3-Inclus�o; 4-Altera��o; 5-Exclus�o)
   // [n][4] - Acesso relacionado a rotina, se esta posi��o n�o for informada nenhum acesso ser� validado
   //----------------------------------------------------------------------------------------------------------

   aAdd(aRotina,{"Fun��o A","ApMsgAlert('Fun��o A')",MODEL_OPERATION_VIEW,0})
   aAdd(aRotina,{"Fun��o B","ApMsgAlert('Fun��o B')",MODEL_OPERATION_VIEW,0})

Return( aRotina )