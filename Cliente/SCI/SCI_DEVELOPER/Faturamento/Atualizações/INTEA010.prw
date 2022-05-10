#include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³EWA010    ºAutor  ³TOTVS				 º Data ³  17/05/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Codificacao Estruturada de Clientes                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 11                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function INTEA010()

Local cAlias	:= GetArea()
Local cCgc		:= M->A1_CGC
Local lCGCBase	:= .f.
Local cCod		:= M->A1_COD
Local cLoja		:= M->A1_LOJA
Local nCont

// cliente ja cadastrado nao pode ter a loja alterada...
If !Inclui
	
	Return( cCgc )
EndIf

// se informado cnpj (pessoa juridica)...
If Len( AllTrim( cCgc ) ) == 14
	
	M->A1_PESSOA:= 'J'
	
	SA1->( dbSetOrder( 3 ) )
	
	// verifico se existe cgc base para utilizar mesmo codigo...
	If SA1->( dbSeek( xFilial( 'SA1' ) + SubStr( cCgc, 1, 8 ), .f. ) )
		
		lCGCBase	:= .t.
		
		M->A1_NOME		:= SA1->A1_NOME
		M->A1_NREDUZ	:= SA1->A1_NREDUZ
		M->A1_HPAGE		:= SA1->A1_HPAGE
		M->A1_NATUREZ	:= SA1->A1_NATUREZ
		M->A1_COND		:= SA1->A1_COND
		M->A1_CONTA		:= SA1->A1_CONTA
		
		cCod	:= SA1->A1_COD
	Else
		// caso contrario defino novo codigo, se ainda nao solicitou...
		If !__lSX8 .or. Empty( cCod ) //M->A1_COD )
			
			cCod	:= GetSxEnum( 'SA1' )
		EndIf
	EndIf
	
	// definicao da loja...
	cLoja	:= '0000'
	
	For nCont := 1 to Val( Substr( cCgc, 9, 4 ) )
		
		cLoja	:= Soma1( cLoja )
		
	Next nCont
	
	// verifica se realmente nao existe o codigo + loja...
	SA1->( dbSetOrder( 1 ) )
	
	While SA1->( dbSeek( xFilial( 'SA1' ) + cCod + cLoja, .f. ) )
		
		If lCGCBase
			
			// se existe cgc base, mudo apenas a loja (este fornecedor ficara com a loja incorreta)...
			cLoja	:= Soma1( cLoja )
		Else
			
			// caso contrario, devo definir um codigo que nao exista...
			While SA1->( dbSeek( xFilial( 'SA1' ) + cCod, .f. ) )
				If !__lSX8 .or. Empty( cCod ) //M->A1_COD )
					cCod	:= Soma1( cCod )
				endIf
			End
		EndIf
	End
Else

	If !Empty(Alltrim(cCgc))
	   M->A1_PESSOA := "F"
	EndIf
	
	SA1->( dbSetOrder( 3 ) )
	
	// verifico se existe CPF base para utilizar mesmo codigo...
	If SA1->( dbSeek( xFilial( 'SA1' ) + cCgc, .f. ) ) .and. !Empty(Alltrim(cCgc))

		cCod    := SA1->A1_COD
		cLoja   := '0000' //'00'
	    
	    SA1->( dbSetOrder( 1 ) )			
       //TARASCONI - 02.07.2008 - PODE EXISTIR O MESMO CPF MUDANDO APENAS A INSCR ESTADUAL
		While SA1->( dbSeek( xFilial( 'SA1' ) + cCod + cLoja, .f. ) )
			// se existe cgc base, mudo apenas a loja (este fornecedor ficara com a loja incorreta)...
			cLoja	:= Soma1( cLoja )
        End

	Else
	   
		cLoja   := '0000'	
		// caso contrario defino novo codigo, se ainda nao solicitou...
		If !__lSX8 .or. Empty( cCod ) //M->A1_COD )
			
			cCod    := GetSxEnum( 'SA1' )
		EndIf
	
	EndIf
	
	// verifica a existencia do cnpj...
	If Empty( cCgc )
		
		M->A1_TIPO	:= 'X'
		cLoja   := '0000'		// modulo easy import control exige loja 01...        
		If !__lSX8 .or. Empty( cCod ) //M->A1_COD )
			cCod    := GetSxEnum( 'SA1' )
		endif
		
	//Else

	//	cLoja   := '01' //'00'
	EndIf

EndIf

M->A1_LOJA    := cLoja
M->A1_COD     := cCod

RestArea( cAlias )

Return( cCGC )