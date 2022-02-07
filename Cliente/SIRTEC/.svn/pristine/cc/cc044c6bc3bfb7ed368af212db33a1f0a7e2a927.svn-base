#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"

/*/{Protheus.doc} MT105QRY 
//Ponto de entrada: Filtro de dados da Mbrowse para ambiente Top. 
@author Celso Rene
@since 28/01/2019
@version 1.0
@type function
/*/
User Function MT105QRY()

	Local _cQuery 	:= ""
	Local _cPerg	:= "XMATA105"
		
	If( FunName() == "U_XMATA105" )
				
		//Gregory A. @ Solutio - Alteração de pergunta para seleção de apenas UMA unidade.
		/*While !Pergunte(_cPerg , .T. ) .or. Empty(MV_PAR01)
			MsgAlert("Selecione uma Unidade para filtro de solicitações.")
		EndDo*/
		
		Pergunte(_cPerg , .T. )

		_cQuery += "  CP_XROT = 'XMATA105' "
		_cQuery += " AND CP_XUNID = '" + MV_PAR01 + "'"
		
	EndIf

	pergunte("MTA105",.F.)

Return(_cQuery)