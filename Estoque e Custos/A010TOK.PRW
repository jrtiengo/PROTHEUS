#INCLUDE "totvs.ch"
#INCLUDE "TopConn.ch"

/*{Protheus.doc}
@Objetivo PE Validação para inclusão ou alteração do Produto ( ) --> lExecuta
@author Junior Tiengo
@since 2909;2021
@version 1.0
@type function/*/

User Function A010TOK()

Local lExecuta  := .T. // Validações do usuário para inclusão ou alteração do produto
Local cUser     := SUPERGETMV("ES_USERSB1", .T., "000000") // SuperGetMv ( cParametro, lHelp, xDefault, cFilial )
    
    Do Case 
       
       Case(Inclui) //inclusao
        
            If (!__cUserID $ cUser .and. Inclui)
                Aviso("Título - Validacao Inclusao", "Mensagem - Usuario Sem Permissao", {"Ok"}, 1)
                lExecuta := .F.
              Else 
                Aviso("Título - Validacao Inclusao", "Mensagem - Usuario Com Permissao", {"Ok"}, 1)
            EndIF
        
        Case(Altera) //alteracao

            If (!__cUserID $ cUser .and. Altera)
                Aviso("Título - Validacao Alteracao", "Mensagem - Usuario Sem Permissao", {"Ok"}, 1)
                lExecuta := .F.
             Else 
                Aviso("Título - Validacao Alteracao", "Mensagem - Usuario Com Permissao", {"Ok"}, 1)
            EndIF
        
        OTHERWISE //caminho alternativo que será seguido caso nenhuma condição especificada nas cláusulas CASE tenha sido avaliada como verdadeira
    EndCase

// GRAVA a inclusão no cadastro de produto
    DbSelectArea("ZZ1")
        RecLock("ZZ1", .T.) // Bloqueia o registro 
            ZZ1->ZZ1_FILIAL  := SB1->B1_FILIAL
            ZZ1->ZZ1_COD     := SB1->B1_COD
            ZZ1->ZZ1_DESC    := SB1->B1_DESC
        MsUnLock() // Confirma e finaliza a operação
    ZZ1->(dbCloseArea())

Return(lExecuta)
