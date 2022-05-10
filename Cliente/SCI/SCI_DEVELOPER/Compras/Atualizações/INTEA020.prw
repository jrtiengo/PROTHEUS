#include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³EWA020    ºAutor  ³Marcelo Tarasconi   º Data ³  17/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Codigo Estruturado de Fornecedores                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function INTEA020()

	Local aAlias	:= GetArea()
	Local cCgc		:= M->A2_CGC
	Local lCGCBase	:= .f.
	Local cCod		:= M->A2_COD
	Local cLoja		:= M->A2_LOJA
	Local nCont		:= 0
	
	
	// fornecedor ja cadastrado nao pode ter a loja alterada...
	If !Inclui
		Return(.T.)
	EndIf
	
	If ReadVar() = "M->A2_CGC"
	
		// se informado cnpj (pessoa juridica)...	
		If Len( AllTrim( cCgc ) ) == 14
			
			M->A2_TIPO := 'J'
			
			SA2->( dbSetOrder( 3 ) )
			
			// verifico se existe cgc base para utilizar mesmo codigo...
			If SA2->( dbSeek( xFilial( 'SA2' ) + SubStr( cCgc, 1, 8 ), .f. ) )
		        		
				lCGCBase := .t.
				
				M->A2_NOME		:= SA2->A2_NOME
				M->A2_NREDUZ	:= SA2->A2_NREDUZ
				M->A2_HPAGE		:= SA2->A2_HPAGE
				M->A2_NATUREZ	:= SA2->A2_NATUREZ
				M->A2_COND		:= SA2->A2_COND
				M->A2_CONTA		:= SA2->A2_CONTA
		
				cCod := SA2->A2_COD
				
			Else
			
				// caso contrario defino novo codigo, se ainda nao solicitou...
				//If !__lSX8 .And. Empty( cCod ) //M->A2_COD )
					
					//cCod := GetSxEnum( 'SA2' )
					cCod := Soma1( A020MaxCod() )
				    
				//EndIf
			EndIf
			
			// definicao da loja...
			cLoja := '0000'
			
			For nCont := 1 To Val( Substr( cCgc, 9, 4 ) )
				
				cLoja := Soma1( cLoja )
				
			Next nCont
			
			// verifica se realmente nao existe o codigo + loja...
		   	SA2->( dbSetOrder( 1 ) )
			
			While SA2->( dbSeek( xFilial( 'SA2' ) + cCod + cLoja, .f. ) )
				
				If lCGCBase
					
					// se existe cgc base, mudo apenas a loja (este fornecedor ficara com a loja incorreta)...
					cLoja	:= Soma1( cLoja )
			
				ELSE
					
					// caso contrario, devo definir um codigo que nao exista...
				   	While SA2->( dbSeek( xFilial( 'SA2' ) + cCod, .f. ) )
						
						// caso contrario defino novo codigo, se ainda nao solicitou...
					 	//If !__lSX8 .And. Empty( cCod ) //M->A2_COD )
					   		cCod	:= Soma1( cCod )
		                //EndIf
					EndDo
				EndIf
		     End
		
		Else
		
			M->A2_TIPO := "F"
			//073833120000170 00610350001141
			SA2->( dbSetOrder( 3 ) )
			
			// verifico se existe CPF base para utilizar mesmo codigo...
			If SA2->( dbSeek( xFilial( 'SA2' ) + cCgc, .f. ) )
		       
				cCod  := SA2->A2_COD
				cLoja := '0000' //'00'
			    
			    SA2->( dbSetOrder( 1 ) )			
		       //TARASCONI - 02.07.2008 - PODE EXISTIR O MESMO CPF MUDANDO APENAS A INSCR ESTADUAL
				While SA2->( dbSeek( xFilial( 'SA2' ) + cCod + cLoja, .f. ) )
				
					// se existe cgc base, mudo apenas a loja (este fornecedor ficara com a loja incorreta)...
					cLoja := Soma1( cLoja )
					
		        EndDo
		
			Else
			   
				cLoja   := '0000'	
				// caso contrario defino novo codigo, se ainda nao solicitou...
				//If !__lSX8 .And. Empty( cCod )//M->A2_COD )
					
					//cCod := GetSxEnum( 'SA2' )
					cCod := Soma1( A020MaxCod() )
					
				//EndIf
			
			EndIf
			
			// verifica a existencia do cnpj...
			/*
			If Empty( cCgc )
				
				M->A2_TIPO := 'X'
				cLoja := '0000'		// modulo easy import control exige loja 01...
				If !__lSX8 .or. Empty( cCod ) //M->A2_COD )
					//cCod := GetSxEnum( 'SA2' ) 
					cCod := Soma1( A020MaxCod() ) 
				EndIf
				
			//Else
		
				//cLoja := '01' //'00'
			EndIf
			*/
			
			/*
			// caso contrario defino novo codigo, se ainda nao solicitou...
			If !__lSX8 .or. Empty( M->A2_COD )
				
				//cCod := GetSxEnum( 'SA2' )
				cCod := Soma1( A020MaxCod() )
			EndIf
			
			// verifica a existencia do cnpj...
			If Empty( cCgc )
				
				M->A2_TIPO	:= 'X'
				cLoja   := '01'		// modulo easy import control exige loja 01...
			Else
				M->A2_TIPO	:= 'F'
				cLoja   := '00'
			EndIf
			*/ 
			
		EndIf
	
	Else
	
		If M->A2_TIPO == 'X'
				
			cLoja := '0000'

			//If !__lSX8 .And. Empty( cCod )
				//cCod := GetSxEnum( 'SA2' )
				cCod := Soma1( A020MaxCod() )  
			//EndIf
				
		EndIf
	
	EndIf
	
	M->A2_LOJA := cLoja
	M->A2_COD  := cCod
		
	//If __lSX8
	//	ConfirmSx8()
	//EndIf
	
	RestArea( aAlias )

Return(.T.)

/* Proximo codigo Fornecedor */

Static Function A020MaxCod()

	Local cQuery := ""
	Local cCod   := ""
	

	cQuery := " SELECT IsNull( MAX( A2_COD ), '' ) A2_COD "
	cQuery += " FROM " + RetSqlName("SA2") 
	cQuery += " WHERE A2_FILIAL  = '" + xFilial("SA2") + "'"     
	cQuery += "   AND D_E_L_E_T_ <> '*'"
                      
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), "MAXSA2", .F., .T.)

	If !Empty( MAXSA2->A2_COD )
		cCod := MAXSA2->A2_COD
	Else
		cCod := StrZero( 0, TamSX3("A2_COD")[1] )
	EndIf
	
	MAXSA2->( dbCloseArea() )

Return( cCod )
