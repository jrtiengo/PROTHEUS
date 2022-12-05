#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function CRM980MDef()

   Local aRotina := {}
   
   //----------------------------------------------------------------------------------------------------------
   // [n][1] - Nome da Funcionalidade
   // [n][2] - Função de Usuário
   // [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
   // [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
   //----------------------------------------------------------------------------------------------------------

   aAdd(aRotina,{"Função A","ApMsgAlert('Função A')",MODEL_OPERATION_VIEW,0})
   aAdd(aRotina,{"Função B","ApMsgAlert('Função B')",MODEL_OPERATION_VIEW,0})

Return( aRotina )