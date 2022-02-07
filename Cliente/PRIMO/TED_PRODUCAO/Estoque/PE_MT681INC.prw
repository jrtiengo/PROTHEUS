#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} MT681INC
//Ponto de entrada: Inclusao do Movimento de Estoque
@author Celso Renee
@since 13/01/2021
@version 1.0
@type function
/*/
User Function MT681INC()

	Local _aArea        := GetArea()
	Local cEsRoTEtiq := SUPERGETMV("ES_ETIQROT",.f.,"01#02") //Roteiros considerados para geração de etiquetas

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1") + SH6->H6_PRODUTO)

	if (!Empty(SD3->D3_OP) .and. SD3->D3_CF == "PR0" )

		dbSelectArea("SB5")
		dbSetOrder(1)
		dbSeek(xFilial("SB5") + SH6->H6_PRODUTO)
		if ( SB5->(Found()) .and. SB5->B5_IMPETI = "1" .and. (SB1->B1_RASTRO == "N" .or. Empty(SB1->B1_RASTRO)) )

			dbSelectArea("SC2")
			dbSetOrder(1)
			dbSeek(xFilial("SC2") + SH6->H6_OP)
			if ( SC2->(Found()) .and. SC2->C2_ROTEIRO $ cEsRoTEtiq)

				dbSelectArea("CB0")
				RecLock("CB0",.T.)
				CB0->CB0_FILIAL	:= xFilial("CB0")
				CB0->CB0_CODETI := SH6->H6_XETIQ
				CB0->CB0_DTNASC	:= dDataBase
				CB0->CB0_TIPO	:= "01" // etiqueta de produto
				CB0->CB0_CODPRO	:= SH6->H6_PRODUTO
				CB0->CB0_QTDE	:= SH6->H6_QTDPROD
				CB0->CB0_USUARI := RetCodUsr()
				CB0->CB0_LOCAL	:= SH6->H6_LOCAL
				CB0->CB0_OP    	:= SH6->H6_OP
				CB0->CB0_NUMSEQ := SD3->D3_NUMSEQ
				CB0->CB0_CC 	:= SD3->D3_CC
				CB0->CB0_ORIGEM := "SH6"
				//CB0->CB0_CLI    := SC2->C2_CLIENTE
				//CB0->CB0_LOJACL	:=
				CB0->(MsUnlock())

			endif

		endif

        /*_cID := CBGrvEti('01', {;   //etiqueta de produto
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
			CtoD(""),;	            //data validade do lote
		    "",;
			"",;
			NIL,;
			"",;
			"",;
			""}) 	                //item documento de entrada
			*/

	endif

	RestArea(_aArea)

Return()

