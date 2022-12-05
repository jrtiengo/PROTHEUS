#include "PROTHEUS.CH"
#Define  CRLF    (chr(13)+chr(10)) 


/*-----------*-------------------------------------------------------------*
 | Fun‡…c      |LEDA520 | Autor | BTI                   | Data | 19-12-2012  |
 *-----------*-------------------------------------------------------------*
 | Descri‡…o   | Acerta os titulos a pagar dos movimentos da folha     |
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
 
User Function LEDA520()	
	Local aSays	 	:= {}
	Local aButtons  	:= {}
	Local nOpca		:= 0
	
	Private cPerg		:= Pad("LEDA520",Len(SX1->X1_GRUPO))
	Private aPerg		:= {}
	Private cAno		:= ""

 	// Registro de Uso de Customizacoes 
	U_LogRdm(ProcName(0),FunName(),Date(),Time(),cUserName)

	Pergunte(cPerg,.F.)
	
	Private cCadastro := OemtoAnsi( "Ajusta SE2 (Contas Pagar) Folha" )
	
	// Cria tela de apresentação
	AADD(aSays,OemToAnsi(' Este programa irá ajustar os titulos do Contas a Pagar (SE2)'))
	AADD(aSays,OemToAnsi(' dos titulos gerados pela folha.'))
	AADD(aSays,OemToAnsi(' Alterando o fornecedor de FOLHA para o codigo do Funcionário'))
	
	AADD( aButtons, { 1, .T., { |o| nOpca := 1,IIf( gpconfOK(), FechaBatch(), nOpca:=0 ) }} )
	AADD( aButtons, { 2, .T., { |o| FechaBatch() } } )
	
	aAdd(aButtons, { 5,.T.,{	|o| Pergunte(cPerg,.T. ) 	}} )
	
	FormBatch( cCadastro, aSays, aButtons )

	If 	nOpca == 1
		Processa({|| F520Proc()}, "Aguarde..", "Ajustando os titulos...")
	Endif
	
Return



Static Function F520Proc()
	Local cQuery 		:= ""
	Local cDtEmissa	:= DTOS(MV_PAR02) 
	Local cDtVencto	:= DTOS(MV_PAR03) 

	// Seleciona os valores diferentes (mais de um funcionário pode receber o mesmo valor, e assim temos titulos iguais)
	cQuery  := " SELECT RC1.RC1_FILTIT, RC1.RC1_MAT, RC1.RC1_NUMTIT,RC1.RC1_VALOR, SE2.E2_VALOR , SE2.R_E_C_N_O_ RECNO "  + CRLF
	cQuery  += " FROM " + RetSQLName('RC1') + " RC1, " + RetSQLName('SE2') + " SE2 "  + CRLF
	cQuery  += " WHERE RC1.RC1_FILTIT = '" + xFilial("SE2") + "' "  + CRLF
	cQuery  += " 	AND RC1.D_E_L_E_T_ <> '*' "  + CRLF
	cQuery  += " 	AND RC1_CODTIT = '" + MV_PAR01 + "' "  + CRLF
	cQuery  += " 	AND RC1.RC1_EMISSA = '" + cDtEmissa + "' "  + CRLF
	cQuery  += " 	AND RC1.RC1_VENCTO = '" + cDtVencto + "' "  + CRLF
	
	cQuery  += " 	AND SE2.E2_PREFIXO = 'GPE' "  + CRLF
	cQuery  += " 	AND SE2.E2_NUM = RC1.RC1_NUMTIT "  + CRLF
	cQuery  += " 	AND SE2.E2_VALOR = RC1.RC1_VALOR "  + CRLF
	cQuery  += " 	AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "  + CRLF
	cQuery  += " 	AND SE2.D_E_L_E_T_ <> '*' "  + CRLF
	cQuery  += "	AND SE2.E2_EMISSAO = '" + cDtEmissa + "' "  + CRLF
	cQuery  += "	AND SE2.E2_VENCTO  = '" + cDtVencto + "' "  + CRLF
	cQuery  += "	AND SE2.E2_BAIXA  = '' "  + CRLF
	cQuery  += "	AND SE2.E2_FORNECE = 'FOLHA' "  + CRLF

MemoWrite("c:\temp\LEDA520_1.SQL",cQuery) 
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	Dbselectarea("TMP")
	DbgoTop()	
	
	While !EOF()
		DBSELECTAREA("SE2")
			DBgoto(TMP->RECNO)
			RECLOCK("SE2", .F.)
				SE2->E2_FORNECE 	:= TMP->RC1_MAT
				SE2->E2_NOMFOR 	:= POSICIONE("SRA",1,xFilial("SRA")+TMP->RC1_MAT,"RA_NOME")
			MSUNLOCK()
		Dbselectarea("TMP")
		TMP->(dbSkip())
	EndDo
	dbselectarea("TMP")   
	TMP->(dbclosearea())

return