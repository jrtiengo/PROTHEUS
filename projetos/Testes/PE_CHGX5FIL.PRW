#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} CHGX5FIL
description A finalidade do ponto de entrada CHGX5FIL � permitir ao usu�rio controlar o acesso das numera��es da Tabela 01 da SX5 (SX5 compartilhada com Tabela 01 exclusiva), 
ou seja, atrav�s do PE � poss�vel filtrar as numera��es/s�ries de notas que ser�o apresentadas no momento do faturamento de acordo com a filial, mesmo com a SX5 compartilhada.
@type function
@version  
@author Tiengo Junior
@since 24/06/2025
@See https://tdn.totvs.com/pages/releaseview.action?pageId=642176751
/*/
 
User Function CHGX5FIL()

      Local cFilSx5 := cFilAnt //Filial que ser� utilizada na filtragem de numera��es/s�ries

Return (cFilSx5)
