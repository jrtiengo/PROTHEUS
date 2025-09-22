#include 'protheus.ch'
#Include "RwMake.ch"
#Include "TopConn.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} MT100GE2
Ponto de entrada para complementar a gravação dos títulos no SE2
Executado após a gravação de cada título
@type function
@version 12.1.33
@author Sistema
@since 2024
@return nil
/*/
User Function MT100GE2()
    Local aArea      := GetArea()
    Local aAreaSEV   := SEV->(GetArea())
    Local cNatPrinc  := ""
    Local nMaiorVal  := 0
    Local cAliasQry  := ""
    
    ConOut("MT100GE2 - Complementando gravação do título")
    
    // Busca a natureza com maior valor na SEV
    cAliasQry := GetNextAlias()
    
    BeginSQL Alias cAliasQry
        SELECT 
            EV_NATUREZ,
            EV_VALOR
        FROM %table:SEV% SEV
        WHERE SEV.%notDel%
            AND EV_FILIAL  = %xFilial:SEV%
            AND EV_PREFIXO = %exp:SE2->E2_PREFIXO%
            AND EV_NUM     = %exp:SE2->E2_NUM%
            AND EV_PARCELA = %exp:SE2->E2_PARCELA%
            AND EV_TIPO    = %exp:SE2->E2_TIPO%
            AND EV_CLIFOR  = %exp:SE2->E2_FORNECE%
            AND EV_LOJA    = %exp:SE2->E2_LOJA%
        ORDER BY EV_VALOR DESC
    EndSQL
    
    If !(cAliasQry)->(Eof())
        cNatPrinc := AllTrim((cAliasQry)->EV_NATUREZ)
        nMaiorVal := (cAliasQry)->EV_VALOR
        
        // Atualiza a natureza do título se necessário
        If !Empty(cNatPrinc) .And. AllTrim(SE2->E2_NATUREZ) != cNatPrinc
            ConOut("MT100GE2 - Atualizando E2_NATUREZ de " + SE2->E2_NATUREZ + " para " + cNatPrinc)
            RecLock("SE2", .F.)
            SE2->E2_NATUREZ := cNatPrinc
            SE2->(MsUnlock())
        EndIf
    EndIf
    
    (cAliasQry)->(DbCloseArea())
    
    RestArea(aAreaSEV)
    RestArea(aArea)
    
Return
