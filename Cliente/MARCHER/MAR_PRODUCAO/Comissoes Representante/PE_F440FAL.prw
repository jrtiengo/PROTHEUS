#include 'protheus.ch'

User Function F440FAL()
	
	Local aFatura := PARAMIXB[1]
	Local lFatura := PARAMIXB[2]
	Local lLiquid := PARAMIXB[3]
	Local cQuery  := ""
	Local aArea   := GetArea()
	Local nPosBase:= 3
	
	//If Empty( aBaixaSE1 )
	If TYPE( 'aBaixaSE1' ) == 'U' .or. empty( 'aBaixaSE1' )
		Return( aFatura )	
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

 	Memowrit( "pe_f440fal.sql", cQuery )
 	
 	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"VLDTIT")

 	// Mudo o valor da Base pelo valor total do título, de todas as parcelas
 	aFatura[ 1, nPosBase ] := VLDTIT->VALOR
	
	DbCloseArea()
	RestArea( aArea )

Return( aFatura )