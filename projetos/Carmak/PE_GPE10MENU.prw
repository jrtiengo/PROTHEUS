#Include 'Protheus.ch'

/*/{Protheus.doc} GPE10MENU
Este Ponto de Entrada permite adicionar opções ao Menu.
@version 1.0 
@author Tiengo Junior
@since 21/08/2025
@type function
@Param Nome a aparecer no cabeçalho
Nome da Rotina associada
Reservado
Tipo de Transação a ser efetuada
        1 - Pesquisa e Posiciona em um Banco de Dados
        2 - Simplesmente Mostra os Campos
        3 - Inclui registros no Bancos de Dados
        4 - Altera o registro corrente
        5 - Remove o registro corrente do Banco de Dados
Nivel de acesso
Habilita Menu Funcional
See https://tdn.totvs.com/pages/releaseview.action?pageId=6079250
/*/

User Function GPE10MENU()

	aAdd(aRotina, { "#Envia TraOS", "u_IntUsr", 0, 7, 0, Nil })

Return(Nil)
