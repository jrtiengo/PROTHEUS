#INCLUDE "protheus.ch"
#Include 'TopConn.ch'
#Include "Totvs.ch"
#Include 'parmtype.ch'
#INCLUDE "Rwmake.ch"


/*{Protheus.doc}
@Objetivo PE Validação para inclusão ou alteração do Produto ( ) --> lExecuta
@author Junior Tiengo
@since 2909;2021
@version 1.0
@type function/*/

User Function A010TOK()

Local lExecuta  := .T.// Validações do usuário para inclusão ou alteração do produto
Local cUser     := SUPERGETMV("ES_USERSB1", .T., "000000") // SuperGetMv ( cParametro, lHelp, xDefault, cFilial )
    
    Do Case 
       
       //inclusao
       Case(Inclui)    
        
            If (!cUser $ __cUserID  .and. Inclui) //!"000000" # cUser
                Aviso("Título - Validacao Inclusao", "Mensagem - Usuario Sem Permissao", {"Ok"}, 1)
            Else 
                Aviso("Título - Validacao Inclusao", "Mensagem - Usuario Com Permissao", {"Ok"}, 1)
            ENDIF 
        
        //alteracao
        Case(Altera)    
            IF !cUser $ __cUserID  .and. Altera
                Aviso("Título - Validacao Alteracao", "Mensagem - Usuario Sem Permissao", {"Ok"}, 1)
            ENDIF
        
        //exclusao
        Case (!Inclui .and. !Altera)
            Aviso("Título - Validacao Exclusao", "Mensagem - Usuario Sem Permissao", {"Ok"}, 1)
        
        OTHERWISE //outro caso

        EndCase

Return(lExecuta)
