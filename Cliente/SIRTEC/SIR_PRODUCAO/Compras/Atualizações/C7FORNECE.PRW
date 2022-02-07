#Include "Protheus.ch"
// Validação no campo C7_FORNECE
// Leef - Machado - 02/06/20 - Chamado 48154
user function frmpag
   if INCLUI
      cXTipo:=sa2->a2_frmpag
   endif
   if empty(cxtipo)
      msgalert("Informe a Forma de Pagamento no Cadastro do Fornecedor", "Atenção - A2_FRMPAG")
      return .f.
   endif      
return .t.
//********************************************************
