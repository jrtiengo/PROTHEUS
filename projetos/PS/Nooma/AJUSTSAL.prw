#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'

User Function FISAL001(p_lJob)

	Default p_lJob := .t.

	If p_lJob
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01RS0001' 
	EndIf
	Processa( { | lEnd | FAJUSTSAL() } , "Ajustando os registros..." )	
	If p_lJob
		RESET ENVIRONMENT
	EndIf
	
Return( Nil )

Static Function FAJUSTSAL()

	Local nCount    := 1
	Local nQtdReg	:= 0	
	Local cAliasTMP := GetNextAlias()
		
	If( Select( cAliasTMP ) > 0 )
		( cAliasTMP )->( DbCloseArea() )
	EndIf	
	
	BeginSql Alias cAliasTMP
				
		SELECT AL_PERFIL, 
			   AL_APROV, 
			   AK_COD, 
			   AK_LIMMIN, 
			   AK_LIMMAX,
			   DHL_LIMMIN, 
			   DHL_LIMMAX,  
			   DHL_COD,
			   AL.R_E_C_N_O_ ALRECNO,
			   DHL.R_E_C_N_O_ DHLRECNO 
		FROM %TABLE:SAK% AK
		INNER JOIN %TABLE:SAL% AL
		 ON AL_APROV = AK_COD
		INNER JOIN %TABLE:DHL% DHL
		 ON DHL_LIMMIN = AK_LIMMIN
		 AND DHL_LIMMAX = AK_LIMMAX
		WHERE AL_PERFIL = ' '
		AND AK.%NOTDEL%
		AND AL.%NOTDEL%
		AND DHL.%NOTDEL%	
			
	EndSql
	
	DbSelectArea( "DHL" )
	DbSelectArea( "SAL" )
	DbSelectArea( cAliasTMP )
	( cAliasTMP )->( DbGoTop() )
	
	MsAguarde( {|| CursorWait() , ( cAliasTMP )->( DbEval( { || nQtdReg++ } ) ) , CursorArrow() } , "Verificando Quantidade de Registros..." )
	
	ProcRegua( nQtdReg )	
	
	( cAliasTMP )->( DbGoTop() )
	While( ( cAliasTMP )->( .NOT. EOF() ) )
	
		IncProc( AllTrim( Str( nCount ) ) + " de " + AllTrim( Str( nQtdReg ) ) )
	
		SAL->( DbGoTo( ( cAliasTMP )->ALRECNO ) )
		DHL->( DbGoTo( ( cAliasTMP )->DHLRECNO ) )
		
		If( Reclock( "SAL" , .F. ) )
			
			SAL->AL_PERFIL := DHL->DHL_COD
			SAL->( MsUnlock() )
			
		EndIf
		
		( cAliasTMP )->( DbSkip() )
			
	End			
	
	Alert( "Processo concluído!" )
			
	( cAliasTMP )->( DbCloseArea() )
	SAL->( DbCloseArea() )
	DHL->( DbCloseArea() )
	
Return( Nil )
