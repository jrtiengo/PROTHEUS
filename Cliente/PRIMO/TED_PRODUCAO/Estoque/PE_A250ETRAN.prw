#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} A250ETRAN
//Ponto de entrada e executado apos gravacao total dos movimentos, na inclusao do apontamento de producao simples.
@author Celso Renee
@since 14/01/2021
@version 1.0
@type function
/*/
User Function A250ETRAN()

	Local _aArea        := GetArea()
	Local _cID          := ""

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SD3->D3_COD)

	if (Found() .and. !Empty(SD3->D3_OP))
		_cID := CBGrvEti('01', {;   //etiqueta de produto
			SD3->D3_COD,;	        //produto
		    SD3->D3_QUANT,;
			"",;
			"",;                	//documento
		    "",;	                //serie documento
		    "",;	                //fornecedor
		    "",;                    //loja
		    "",;
			"",; 		    		//endereco
		    SD3->D3_LOCAL,;	        //local
		    SD3->D3_OP,;			//OP
		    SD3->D3_NUMSEQ,;    	//Num Seq.
		    NIL,;
			NIL,;
			NIL,;
			"",;	                //lote
		    "",;
			DtoC(""),;	            //data validade do lote
		    "",;
			"",;
			NIL,;
			"",;
			"",;
			""}) 	                //item documento de entrada

	endif

	

	
	RestArea(_aArea)
	

Return()
