#INCLUDE "rwmake.ch" 

// Jean Rehermann | JPC - Após a abertura de OP amarrada a um PV
User Function MA650GRPV()

   U_AUTOM628("PE_MA650GRPV")
   
    If SC6->C6_OP == "01"
		RecLock("SC6",.F.)
			SC6->C6_STATUS := "07" // Em produção (pedido com OP em aberto)
			U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "07", "PE_MA650GRPV") // Gravo o log de atualização de status na tabela ZZ0
		MsUnLock()
	EndIf

Return()
