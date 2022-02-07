#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"    
#INCLUDE 'TOTVS.CH'   
#Define CRLF  CHR(13)+CHR(10)

                                            
User Function CRIAZNF()   
	   
	Local cAlias   := ' '
  	Local aEmpSmar := {}
  	Local aEmpNFe  := {}
  	Local aInfo   := {}
  	Local aTables := {"SA1","SA2","SF1","SD1","SF2","SD2","CTT","ZNF", "SF4","SB6","SB1","CT1",'SX6'}//seta as tabelas que serão abertas no rpcsetenv
  	cError      := "" // Tratamento para erros não amigaveis finalizar a tela.
  	oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
   	

	RpcSetEnv( '01',, " ", " ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/
		 	                                                                                                       
	dbSelectarea('SM0')
	SM0->(dbGotop())
	      	
	Do While SM0->(!Eof())	    			
		Aadd(aEmpSmar,{SM0->M0_CODIGO,SM0->M0_CODFIL})		  			
		SM0->(dbSkip())			
  Enddo		
	   	   	
	RpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	
		   	   	
	cEmpABax := aEmpSmar[1][1]     
	RpcSetEnv( aEmpSmar[1][1],," " ," " , "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/
		
	For n:=1 to Len(aEmpSmar)
			
		//If Select('ZNF') > 0
			dbselectArea("ZNF")	
			dbGotop()
			dbCloseArea()
		//sEndif
			
		//SRpcClearEnv() //RESET ENVIRONMENT //->[CRITICA] - Remover o RESET ENVIRONMENT desse ponto	   	                                     
		cEmpABax := aEmpSmar[n][1]
		RpcSetEnv( cEmpABax," " ," ", "COM", "MATA103", aTables, , , ,  )/****** COMANDOS *************/			
		
	Next	
	
				   
	RpcClearEnv()
	
Return