#Include 'Protheus.ch'
#Include "Tbiconn.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ACERTISS
Retorno do número do título.
@type function
@author Eliane Carvalho
@since 17/09/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User function TedNumDoc()
    
	Local cNumdoc:=''

    cNumdoc:= Substr(SE1->E1_NUM,3,7) 
	If !EMPTY(SE1->E1_PARCELA)
		cNumdoc+=STRZERO(VAL(SE1->E1_PARCELA),3)
	Else
		cNumdoc+='001'
	Endif
		
Return (cNumdoc)

