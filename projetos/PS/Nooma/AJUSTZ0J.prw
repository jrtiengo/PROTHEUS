#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'

User Function FIZ0J001(p_lJob)

	Default p_lJob := .t.

	If p_lJob
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01RS0001' 
	EndIf
	Processa( { | lEnd | FAJUSTZ0J() } , "Ajustando os registros..." )	
	If p_lJob
		RESET ENVIRONMENT
	EndIf

Return( Nil )

Static Function FAJUSTZ0J()

	Local nCount    := 1
	Local nQtdReg	:= 0	
	Local cAliasTMP := GetNextAlias()
		
	If( Select( cAliasTMP ) > 0 )
		( cAliasTMP )->( DbCloseArea() )
	EndIf	
	
	BeginSql Alias cAliasTMP
				
		SELECT Z0J_PERFIL, 
			   Z0J_APROV, 
			   AK_COD, 
			   AK_LIMMIN, 
			   AK_LIMMAX,
			   DHL_LIMMIN, 
			   DHL_LIMMAX,  
			   DHL_COD,
			   Z0J.R_E_C_N_O_ ALRECNO,
			   DHL.R_E_C_N_O_ DHLRECNO 
		FROM %TABLE:SAK% AK
		INNER JOIN %TABLE:Z0J% Z0J
		 ON Z0J_APROV = AK_COD
		INNER JOIN %TABLE:DHL% DHL
		 ON DHL_LIMMIN = AK_LIMMIN
		 AND DHL_LIMMAX = AK_LIMMAX
		WHERE Z0J_PERFIL = ' '
		AND AK.%NOTDEL%
		AND Z0J.%NOTDEL%
		AND DHL.%NOTDEL%	
			
	EndSql
	
	DbSelectArea( "DHL" )
	DbSelectArea( "Z0J" )
	DbSelectArea( cAliasTMP )
	( cAliasTMP )->( DbGoTop() )
	
	MsAguarde( {|| CursorWait() , ( cAliasTMP )->( DbEval( { || nQtdReg++ } ) ) , CursorArrow() } , "Verificando Quantidade de Registros..." )
	
	ProcRegua( nQtdReg )	
	
	( cAliasTMP )->( DbGoTop() )
	While( ( cAliasTMP )->( .NOT. EOF() ) )
	
		IncProc( AllTrim( Str( nCount ) ) + " de " + AllTrim( Str( nQtdReg ) ) )
	
		Z0J->( DbGoTo( ( cAliasTMP )->ALRECNO ) )
		DHL->( DbGoTo( ( cAliasTMP )->DHLRECNO ) )
		
		If( Reclock( "Z0J" , .F. ) )
			
			Z0J->Z0J_PERFIL := DHL->DHL_COD
			Z0J->( MsUnlock() )
			
		EndIf
		
		( cAliasTMP )->( DbSkip() )
			
	End			
	
	Alert( "Processo concluído!" )
			
	( cAliasTMP )->( DbCloseArea() )
	Z0J->( DbCloseArea() )
	DHL->( DbCloseArea() )
	
Return( Nil )
