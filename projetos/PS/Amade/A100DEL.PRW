#include "rwmake.ch"      

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  A100DEL ³ Autor ³ Rogerio Batista        ³ Data ³ 11/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PE executado antes da exclusao da nota NFE.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se MSFIL e igual a filial ativa.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
User Function A100DEL()   
Local lRet  := .T.

If AllTrim( SF1->F1_MSFIL ) <> AllTrim( SM0->M0_CODFIL )
   Alert( "ATENCAO!!!  NF/SERIE " + SF1->( F1_DOC + "/" + F1_SERIE ) + " pertence a outra filial." )
   lRet := .F.
EndIf

//Validação para não permitir a exclusão da nota, se a nota já foi despachada.

	If SF1->F1_ZSTSWMS = '2'

		FWAlertError("Nota já despachada pelo WMS", "Cancelamento não autorizado")
		lRet := .F.
	Else

		If Empty(SF1->F1_ZCANCW)

			RecLock("SF2",.F.)

			SF1->F1_ZCANCW := '1' //Cancelamento solicitado 

			SF1->(MSUnLock())

			FWAlertSucess("Solicitação de Cancelamento Enviado ao WMS", "Cancelamento WMS")
         lRet := .F.
			
		ElseIf SF1->F1_ZCANCW == '1'
			
			FWAlertWarning("Aguardando retorno WMS", "Cancelamento")
         lRet := .F.
		
		ElseIf SF1->F1_ZCANCW == '3'
		
			FWAlertError("Cancelamento não autorizado pelo WMS", "Cancelamento")
         lRet := .F.
		Endif
	Endif

Return lRet
