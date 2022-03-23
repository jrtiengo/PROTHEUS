#INCLUDE "Protheus.ch"

// #########################################################################################
// Projeto: Comissões
// Modulo : Financeiro
// Fonte  : PE_FA440VLD.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 03/10/2017 | Jorge Alberto     | Criado o PE para validar se deve ou não gerar registro  
//            |                   | de Comissão na tabela SE3.                  
// -----------+-------------------+---------------------------------------------------------
User Function FA440VLD()

	Local lRet := .T.
	Local cQuery := ""
	Local aArea := GetArea()
	Local nSaldo := 0
	
	// Se não passou pelo PEF070BTOK() que declara e carrega a variavel aBaixaSE1, então seta vazio 
	// aqui e segue o fluxo para gerar comissão.
	//If Empty( aBaixaSE1 )
	alert(TYPE( 'aBaixaSE1' ))
	alert(iif(empty( aBaixaSE1 ),'true','false'))
	
	If TYPE( 'aBaixaSE1' ) == 'U' .or. empty( aBaixaSE1 )
		Return( lRet )
	EndIf

	// Soma o Saldo do título de todas as Parcelas que tiver
	cQuery += "SELECT SUM( E1_SALDO ) SALDO "
	cQuery += "FROM " + RetSqlName("SE1") + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' " 
	cQuery += "AND E1_FILIAL = '" + aBaixaSE1[ 1 ] + "' "
 	cQuery += "AND E1_PREFIXO = '" + aBaixaSE1[ 2 ] + "' "
 	cQuery += "AND E1_NUM = '" + aBaixaSE1[ 3 ] + "' "
 	cQuery += "AND E1_CLIENTE = '" + aBaixaSE1[ 4 ] + "' "
 	cQuery += "AND E1_LOJA = '" + aBaixaSE1[ 5 ] + "' "

 	Memowrit( "pe_fa440vld.sql", cQuery )
 	
 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SLDTIT")
 	
 	// Array aBaixaSE1 foi carregado no PE F070BTOK()
 	nSaldo := SLDTIT->SALDO - aBaixaSE1[ 6 ]
 	
	If nSaldo > 0
		//MsgInfo( "Saldo do título "+ aBaixaSE1[ 2 ] + "/" + AllTrim( cValToChar( aBaixaSE1[ 3 ] ) ) + " é R$ " + AllTrim( Transform( nSaldo, "@E 999,999,999,999.99" ) ) + " portanto não será gerada Comissão." )
		lRet := .F.
	//Else
		//MsgInfo( "Saldo do título é zero então terá Comissão !" )
	EndIf
	
	DbCloseArea()
	
	RestArea( aArea )
	
Return( lRet )
