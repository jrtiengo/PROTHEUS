#include "Protheus.ch"


/*/{Protheus.doc} MT140ISV
Recupera do XML o Código de Serviço no uso do Totvs Transmite
@type function
@version V 1.00
@author Marcio Martins
@since 27/10/2023
@obs Consultores que auxiliaram Mariana Cardoso / Wagner Nunes
@return character, Retorna dados do XML
/*/
User Function MT140ISV()

    Local cRet := ""
    Local cXML := ""
    Local nInicio := 0
    Local nFinal := 0

    dbSelectArea("CKO")
    CKO->(dbSetOrder(1))
    If CKO->(dbSeek(xFilial("CKO")+SDS->DS_ARQUIVO))
        cXML := CKO->CKO_XMLRET
		nInicio := AT('<itemListaServ>',cXML)	// Marcio M. 30/10/2023 - Para Evitar erro caso não encontre
		If nInicio > 0 
			nInicio := AT('<itemListaServ>',cXML)+15
			nFinal := AT('</itemListaServ>',cXML)
			cRet := SubStr(cXML,nInicio,nFinal-nInicio)
		Endif 
	Endif 

Return cRet
