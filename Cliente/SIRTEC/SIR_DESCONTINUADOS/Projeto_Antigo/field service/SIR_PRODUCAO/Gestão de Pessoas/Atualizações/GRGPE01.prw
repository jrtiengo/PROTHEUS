#include "protheus.ch"

/*
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRGPE01   ºAutor  ³ Felipe Maia	     º Data ³  26/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa chamado pelo roteiro de cálculo para efetuar o   º±±
±±º          ³  calculo das compensacoes de horas Sirtec                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP12                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GRGPE01()

	Private n_Gera := 0
       
        IF (( FBUSCAPD("846,847",'H',,)>0 ).AND.( FBUSCAPD("849,850",'H',,)>FBUSCAPD("847,846",'H',,) ))    
           
        	n_Gera := FBUSCAPD("849,850",'H',,)-FBUSCAPD("847,846",'H',,)
        	         
            FGERAVERBA("418",0,n_Gera,,,'H',"G",,,,.T.,,,,)   
            
            FDELPD("418",,) 
            
            n_Gera := 0
    
                
        EndIF
    
    
        IF (( FBUSCAPD("847",'H')<=0 ).AND.( FBUSCAPD("846",'H')>FBUSCAPD("849,850",'H',,)))
        
        	n_Gera := FBUSCAPD("846",'H',,)-FBUSCAPD("849,850",'H',,)
        	
             
            FGERAVERBA("140",0,n_Gera,,,'H',"G",,,,.T.,,,,)       
            
             n_Gera := 0    
            
    
        EndIF
    
    
        IF ( FBUSCAPD("847",'H',,)>FBUSCAPD("849,850",'H',,)) 
        
        	n_Gera := FBUSCAPD("847",'H',,)-FBUSCAPD("849,850",'H',,)          	
             
            FGERAVERBA("147",0,n_Gera,,,'H',"G",,,,.T.,,,,)
            
            IF n_Gera > 0
    		
    		FGERAVERBA("140",0,FBUSCAPD("846",'H',,),,,'H',"G",,,,.T.,,,,)   
    		
    		EndIF   
    
             n_Gera := 0 
    
        EndIF
    
    
        IF (( FBUSCAPD("847",'H',,)>0 ).AND.( FBUSCAPD("849,850",'H',,)>FBUSCAPD("847",'H',,) ).AND.( FBUSCAPD("849,850",'H',,)<FBUSCAPD("847,846",'H',,) ))
  		 
  			n_Gera :=FBUSCAPD("846,847",'H',,)-FBUSCAPD("849,850",'H',,)     
  			
  		    
   			FGERAVERBA("140",0,n_Gera,,,'H',"G",,,,.T.,,,,) 
   			
   			n_Gera := 0      			
    
                
        EndIF      
        
        
         IF FBUSCAPD("847",'H',,)- FBUSCAPD("849,850",'H',,)= 0
  		 
  		 	n_Gera :=FBUSCAPD("846",'H',,)  
  			
  		    
   			FGERAVERBA("140",0,n_Gera,,,'H',"G",,,,.T.,,,,) 
   			
   			n_Gera := 0      			
    
                
        EndIF
    
    
        IF ( FBUSCAPD("847,846",'H',,)=FBUSCAPD("849,850",'H',,))
    
            FGERAVERBA("147",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("140",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("418",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("419",0,0,,,'H',"G",,,,.T.,,,,)
    
        EndIF
    
    
Return