#include "PROTHEUS.CH"
#Define  CRLF    (chr(13)+chr(10)) 


/*-----------*-------------------------------------------------------------*
 | Fun‡…c      |LEDA510 | Autor | BTI                   | Data | 19-12-2012  |
 *-----------*-------------------------------------------------------------*
 | Descri‡…o   | Cadastra os Funcionários (SRA) como fornecedores (SA2)      |
 |           |                                                             |
 *-----------*-------------------------------------------------------------*
 |  Parametro| Nenhum			                                           |
 *-----------*-------------------------------------------------------------*
 |  Retorno  | Nenhum                                                      |
 *-----------*-------------------------------------------------------------*
 |  Uso      | Doces Ledur          					                      |
 *-----------*-------------------------------------------------------------*
 |  ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      |
 *---------------*--------*------*-----------------------------------------*
 |  PROGRAMADOR  | DATA   | BOPS |  MOTIVO DA ALTERACAO                    |
 *---------------*--------*------*-----------------------------------------*
 |               |        |      |                                         |
 *---------------*--------*------*-----------------------------------------*/
 
User Function LEDA510()
	Private aSays         := { }
	Private aButtons      := { } 
	Private cCadastro     := OemToAnsi('Cadastro Funcionários -> Fornecedores')
	Private nOpca         := 0
	
 	// Registro de Uso de Customizacoes 
	U_LogRdm(ProcName(0),FunName(),Date(),Time(),cUserName)
	
	AADD(aSays,OemToAnsi(' Este programa tem o objetivo de cadastrar os Funcionários ' ) )  
	AADD(aSays,OemToAnsi(' como Fornecedores e Clientes. ' ) )  
	
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpconfOK(),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
	    
	If nOpca == 1
		Processa({|lEnd| Cadastra() ,"Cadastrando Funcionarios..."})
	EndIf
	
Return Nil
 
 
Static Function Cadastra()
	Local aArea      := GetArea()

	DbSelectArea("SRA")
	DbSetOrder(1)
	DbGoTop()

	ProcRegua(RecCount())

	While !Eof()
		IncProc()
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2") + SRA->RA_MAT + "00",.T.)
		If !found()
			Reclock("SA2",.T.)
				SA2->A2_FILIAL 		:= xFilial("SA2")
				SA2->A2_COD 		:= SRA->RA_MAT
				SA2->A2_LOJA 		:= "00"
				SA2->A2_NOME 		:= SRA->RA_NOME
				SA2->A2_NREDUZ 		:= SRA->RA_NOME
				SA2->A2_TEL	 		:= SRA->RA_TELEFON
				SA2->A2_END 		:= SRA->RA_ENDEREC + SRA->RA_COMPLEM 
				SA2->A2_BAIRRO 		:= SRA->RA_BAIRRO
				SA2->A2_EST 		:= SRA->RA_ESTADO
				SA2->A2_COD_MUN 	:= POSICIONE("CC2",2,xFilial("CC2")+SRA->RA_MUNICIP,"CC2_MUN")
				SA2->A2_MUN 		:= SRA->RA_MUNICIP
				SA2->A2_CEP 		:= SRA->RA_CEP
				SA2->A2_TIPO 		:= "F"
				SA2->A2_CGC 		:= SRA->RA_CIC
				SA2->A2_INSCR 		:= "ISENTO"
				SA2->A2_PAIS 		:= "105"
				SA2->A2_CODPAIS 	:= "01058"
			MsUnLock()
		Endif

		cCodCli := U_LeGetNumCli()
		dbSelectArea("SA1")
		dbSetOrder(3)
		dbSeek(xFilial("SA1") + SRA->RA_CIC,.T.)
		If !found()
			Reclock("SA1",.T.)
				SA1->A1_FILIAL	:= xFilial("SA1")
				SA1->A1_COD		:= cCodCli
				SA1->A1_LOJA	:= "01"
				SA1->A1_NOME	:= SRA->RA_NOME
				SA1->A1_NREDUZ	:= SRA->RA_NOME
				SA1->A1_END		:= AllTrim(SRA->RA_ENDEREC) + AllTrim(SRA->RA_COMPLEM)
				SA1->A1_ENDCOB	:= AllTrim(SRA->RA_ENDEREC) + AllTrim(SRA->RA_COMPLEM)
				SA1->A1_COD_MUN	:= POSICIONE("CC2",2,xFilial("CC2")+SRA->RA_MUNICIP,"CC2_CODMUN")
				SA1->A1_MUN		:= SRA->RA_MUNICIP
				SA1->A1_MUNC	:= SRA->RA_MUNICIP
				SA1->A1_EST		:= SRA->RA_ESTADO
				SA1->A1_BAIRRO	:= SRA->RA_BAIRRO
				SA1->A1_CODBAIR	:= "10"
				SA1->A1_CEP		:= SRA->RA_CEP
				SA1->A1_CEPC	:= SRA->RA_CEP
				SA1->A1_DDD		:= "51"
				SA1->A1_TEL		:= SRA->RA_TELEFON
				SA1->A1_CGC		:= SRA->RA_CIC
				SA1->A1_EMAIL	:= "vendas@bomprincipio.com.br"
				SA1->A1_COMPLEM	:= "" 
				SA1->A1_OBS1	:= "FUNCIONARIO"
				SA1->A1_PESSOA 	:= "F"
				SA1->A1_TIPO	:= "F"
				SA1->A1_PAIS	:= "105"
				SA1->A1_INSCR	:= "ISENTO"
				SA1->A1_VEND	:= "28"
				SA1->A1_REGIAO	:= "009"
				SA1->A1_CONTA	:= U_LEDG002( cCodCli, "01", SRA->RA_NOME)
				SA1->A1_TPFRET	:= "C"
				SA1->A1_COND	:= "001"
				SA1->A1_MOEDALC	:= 2
				SA1->A1_CODPAIS	:= "01058"
				SA1->A1_RECCOFI	:= "N"
				SA1->A1_RECCSLL	:= "N"
				SA1->A1_RECPIS	:= "N"
				SA1->A1_MSBLQL	:= "2"
				SA1->A1_ABATIMP	:= "3"
				SA1->A1_USADDA	:= "2"
				SA1->A1_FORMPG	:= "01"
				SA1->A1_GRPVEN	:= "000041"
				SA1->A1_B2B		:= "2"
				SA1->A1_MINIRF	:= "2"
				SA1->A1_FLEX	:= "N"
				SA1->A1_FLEX2	:= "N"
				SA1->A1_FLEX3	:= "N"
				SA1->A1_FLEX4	:= "N"
				SA1->A1_FLEX5	:= "N"
				SA1->A1_REGESIM	:= "2"
				SA1->A1_LDBOOK	:= ""
				SA1->A1_PRF_OBS	:= ""
				SA1->A1_TPDP	:= "2"
				SA1->A1_NATUREZ	:= "10100"
				SA1->A1_GRPTRIB	:= "10"
			MsUnLock()
		Else
			Reclock("SA1",.F.)
			SA1->A1_CONTA	:= U_LEDG002( SA1->A1_COD, SA1->A1_LOJA, SA1->A1_NOME)
			MsUnLock()
		Endif

		DbSelectArea("SRA")
		DbSkip()
	EndDo
	dbselectarea("SA1")
	dbclosearea()
	dbselectarea("SA2")
	dbclosearea()
	dbselectarea("SRA")
	dbclosearea()
	RestArea( aArea )
Return 