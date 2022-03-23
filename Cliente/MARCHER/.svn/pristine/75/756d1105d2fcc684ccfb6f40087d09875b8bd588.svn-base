#include 'protheus.ch'

User Function F440BASE()
	
	Local aDados  := PARAMIXB
	Local cQuery  := ""
	Local aArea   := GetArea()
	
	If TYPE( 'aBaixaSE1' ) == 'U' .or. empty( aBaixaSE1 ) .Or. Empty( PARAMIXB )
//If Empty( aBaixaSE1 ) .Or. Empty( PARAMIXB )
		Return( aDados )	
	EndIf
	
	// Soma o Saldo do título de todas as Parcelas que tiver
	cQuery += "SELECT SUM( E1_VALOR ) VALOR "
	cQuery += "FROM " + RetSqlName("SE1") + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' " 
	cQuery += "AND E1_FILIAL = '" + aBaixaSE1[ 1 ] + "' "
 	cQuery += "AND E1_PREFIXO = '" + aBaixaSE1[ 2 ] + "' "
 	cQuery += "AND E1_NUM = '" + aBaixaSE1[ 3 ] + "' "
 	cQuery += "AND E1_CLIENTE = '" + aBaixaSE1[ 4 ] + "' "
 	cQuery += "AND E1_LOJA = '" + aBaixaSE1[ 5 ] + "' "

 	Memowrit( "pe_f440base.sql", cQuery )
 	
 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"VLDTIT")
 	
 	/*
	ParamIXB[1] cVendedor,;
	ParamIXB[2] SE1->E1_VLCRUZ,;
	ParamIXB[3] nBaseEmis,;
	ParamIXB[4] nBaseBaix,;
	ParamIXB[5] nVlrEmis,;
	ParamIXB[6] nVlrBaix,;
	ParamIXB[7] nPerComis
	*/
	
 	// Mudo o valor da Base pelo valor total do título, de todas as parcelas
 	aDados[ 1, 3 ] := VLDTIT->VALOR
 	aDados[ 1, 5 ] := aDados[ 1, 3]  * (aDados[ 1, 7 ]/100)// novo valor
	
	DbCloseArea()
	RestArea( aArea )
	
	Alert( cValToChar( aDados[ 1,3 ] ) )

Return( aDados )
