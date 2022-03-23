/*/{Protheus.doc} F240Grv

Este ponto de entrada já era utilizado para gravar o campo customizado
EA_XSISPAG. Passo a tratar o bloco J52 que passou a ter sua obrigatoriedade
para qualquer valor. (anteriormente o bloco J52, só era obrigatório para
valores a partir de R$250.000,00)

@type function
@author Peder Munksgaard (Criare Consulting)
@since 05/06/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

#Include "Protheus.ch"

User Function F240Grv()
	
	// Peder Munksgaard (Criare Consulting) - 05/06/2017
	
	Local cDetJ52   := ""
	Local cModelo	  := SEA->EA_MODELO
	Local cLocaBco  := ""
	Local cLocaPro  := ""
	
	Do Case
		
	Case cModelo == "30"  // Liquidacao de titulos em cobranca no Ita£
		cHeadLote := "C"
		cDeta     := "J"
		cDetJ52   := "5"
		cTraiLote := "E"
	Case cModelo == "31"  // Pagamento de titulos em outros bancos
		cHeadLote := "C"
		cDeta     := "J"
		cDetJ52   := "5"
		cTraiLote := "E"
		
	Endcase
	
	// Conforme orientação do key user Giovani (FIN), o modelo 30 também deverá gerar o registro J52.
	// Como o fonte padrão gera o registro para modelo 31 e valores maiores ou iguais a 250000, então
	// faço a trativa também para o modelo 31 e valores menores que 250000.
	
   	If cModelo == "30" .Or. (cModelo == "31")
	    
		nSeq++
		Fa240Linha( cDetJ52 ,@cLocaBco,@cLocaPro)
		
	EndIf
	//
	
    //RecLock("SEA",.F.)
    //SEA->EA_XSISPAG := "1"
   //MsUnLock()
  //DbCommit()
	
Return