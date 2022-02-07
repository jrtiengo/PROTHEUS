#include "protheus.ch"

/*
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GRGPE02   �Autor  � Felipe Maia	     � Data �  26/01/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Programa chamado pelo roteiro de c�lculo para efetuar o   ���
���          �  calculo das compensacoes de horas sino                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP12                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GRGPE02()

	Private n_Gera := 0    
	
   		IF (( FBUSCAPD("846,847,848",'H',,)>0 ).AND.( FBUSCAPD("849,850",'H',,)>FBUSCAPD("847,846,848","H",,) ))
    
      	n_Gera := FBUSCAPD("849,850",'H',,)-FBUSCAPD("846,847,848",'H',,)      
      	
      	FGERAVERBA("418",0,n_Gera,,,'H',"G",,,,.T.,,,,) 
      	
      	FDELPD("418",,)
    
        n_Gera := 0	
    
        EndIF   
        
        
        IF ( FBUSCAPD("848",'H',,)>FBUSCAPD("849,850","H",,))
    
            n_Gera := FBUSCAPD("848",'H',,)-FBUSCAPD("849,850",'H',,)   
            
            FGERAVERBA("148",0,n_Gera,,,'H',"G",,,,.T.,,,,)      
            
            IF n_Gera > 0
    		
    		FGERAVERBA("140",0,FBUSCAPD("846",'H',,),,,'H',"G",,,,.T.,,,,)   
    		
    		EndIF   
    		
    		IF n_Gera > 0
    		
    		FGERAVERBA("147",0,FBUSCAPD("847",'H',,),,,'H',"G",,,,.T.,,,,)   
    		
    		EndIF
    		
    	           
             n_Gera := 0
                   
        EndIF
    
    IF (( FBUSCAPD("848",'H',,)>0 ).AND.( FBUSCAPD("849,850",'H',,)>FBUSCAPD("848","H",,) ).AND.( FBUSCAPD("849,850",'H',,)<FBUSCAPD("848,847","H",,) ))
    
           	n_Gera := FBUSCAPD("848,847",'H',,)-FBUSCAPD("849,850",'H',,)
    
    		FGERAVERBA("147",0,n_Gera,,,'H',"G",,,,.T.,,,,)
    		
    		IF n_Gera > 0
    		
    		FGERAVERBA("140",0,FBUSCAPD("846",'H',,),,,'H',"G",,,,.T.,,,,)   
    		
    		EndIF
    		
    		n_Gera := 0
    
        EndIF          
        
        IF (( FBUSCAPD("847,848,846",'H',,)>0 ).AND.( FBUSCAPD("849,850",'H',,)>FBUSCAPD("847,848","H",,) ).AND.( FBUSCAPD("849,850",'H',,)<FBUSCAPD("846,847,848","H",,) ))
    
            n_Gera := FBUSCAPD("848,847,846",'H',,)-FBUSCAPD("849,850",'H',,) 
            
            FGERAVERBA("140",0,n_Gera,,,'H',"G",,,,.T.,,,,) 
    		
    		n_Gera := 0
    
        EndIF  
        
        IF ( FBUSCAPD("847,846,848",'H',,)=FBUSCAPD("849,850","H",,))
    
            FGERAVERBA("147",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("148",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("140",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("418",0,0,,,'H',"G",,,,.T.,,,,)
    
            FGERAVERBA("419",0,0,,,'H',"G",,,,.T.,,,,)
    
        EndIF     
        
    Return