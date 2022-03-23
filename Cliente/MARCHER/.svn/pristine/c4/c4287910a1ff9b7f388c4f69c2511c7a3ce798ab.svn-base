#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} MT121BRW
Itens no menu pedido de compra
@author koliveira
@since 14/12/2017
@version 1.0
@return aRotina, Botões adicionais da rotina
@see MATA121
/*/
User Function MT120BRW()
	
	AADD( aRotina, { "Alteração Data Entrega "	, "U_SOLTADTAE()"		, 0, 4} )
	AADD( aRotina, { "Imprimir Pedido "	, "U__Matr110('SC7',SC7->(recno()),1)"		, 0, 4} )
	If ExistBlock( "MARR003" )
		AADD( aRotina, { "Impr. PDF Rel p/ Fornece"	, "U_MARR003(SC7->C7_NUM,.T.)"		, 0, 4} )
	Endif
	If ExistBlock( "MARR003" ) .and. ExistBlock( "PDFPCML" )
		AADD( aRotina, { "Envia PDF Email Fornece"	, "ExecBlock('PDFPCML',.F.,.F.,{SC7->C7_NUM,'PC',2,SC7->C7_FILIAL})"		, 0, 4} )
	Endif
Return  