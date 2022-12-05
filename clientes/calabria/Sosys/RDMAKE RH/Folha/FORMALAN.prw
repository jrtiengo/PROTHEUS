#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} FormaLan
 Essa função de usuário foi criada com base no layout
 Cnab Modelo 2 240 posições do Santander p/ Folha de Pagamento;
 Ela exemplifica a utilização da variável cLote para escolha da
 forma de lançamento, no nosso exemplo baseada nas informações do
 Layout do Santander;
@author PHILIPE.POMPEU
@since 21/06/2016
@version P12.1.6
@return cReturn, forma de lançamento
/*/
User Function FormaLan()
	Local cReturn := "03"	
	if(cLote != Nil)
		/*cLote é sempre: cCodBanco+TpContaSal OU 'DOC'+TpContaSal, sendo 'DOC' usado
		para qualquer outro banco diferente de cCodBanco.*/		
		Do Case
			Case (Right(cLote,1) == ' ' )
				cReturn := "10"
			Case (cCodBanco == Left(cLote,3))
				if(Right(cLote,1) == '1')
					cReturn := "01"
				elseif(Right(cLote,1) == '2')
					cReturn := "05"	
				endIf
			Case ("DOC" 	  == Left(cLote,3))
				cReturn := "03"		
		EndCase
	endIf
Return cReturn