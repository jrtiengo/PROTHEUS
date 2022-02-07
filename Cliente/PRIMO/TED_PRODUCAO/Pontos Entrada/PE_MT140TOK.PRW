#INCLUDE "PROTHEUS.CH"
/*/-----------------------------------------------------------------------------------/
{Protheus.doc} MT140TOK
Pode ser usado para validar a inclusao da pré-NF.
@obs Programa Fonte: MATA140.PRW
@type  Function
@author Márcio Borges - Solutio IT
@since 30/11/2021
@return logical, lRet - (LÓGICO) .T. se todas as validações OK ou .F. se houver problema
/-----------------------------------------------------------------------------------/*/
User Function MT140TOK()

	Local lRet      := PARAMIXB[ 1 ]
	Local aArea     := GetArea()



	//Validação Quantidade Caracteres Documento de Entrada
	If INCLUI .AND.  !(cTipo $ "D") .AND. cFormul<>"S"
		If !U_TEDA030(cNFiscal)
			lRet := .F.
			Return( lRet )
		Endif
	EndIf


	RestArea( aArea )

Return( lRet )
