#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} CHGX5FIL
description A finalidade do ponto de entrada CHGX5FIL é permitir ao usuário controlar o acesso das numerações da Tabela 01 da SX5 (SX5 compartilhada com Tabela 01 exclusiva), 
ou seja, através do PE é possível filtrar as numerações/séries de notas que serão apresentadas no momento do faturamento de acordo com a filial, mesmo com a SX5 compartilhada.
@type function
@version  
@author Tiengo Junior
@since 24/06/2025
@See https://tdn.totvs.com/pages/releaseview.action?pageId=642176751
/*/
 
User Function CHGX5FIL()

      Local cFilSx5 := cFilAnt //Filial que será utilizada na filtragem de numerações/séries

Return (cFilSx5)
