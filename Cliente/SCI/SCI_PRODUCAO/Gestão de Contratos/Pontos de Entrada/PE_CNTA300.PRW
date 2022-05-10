#INCLUDE "TOTVS.CH"         
#INCLUDE "FWMVCDEF.CH"
/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | CNTA300 | Autor | Maia 			  		 | Data |30/08/17  |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | ponto de entrada para (CNTA300) "Inclusão (Compras)"	   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/ 

User Function CNTA300()          

Local aAreaAtu    := GetArea()
Local xRet       := .T.
Local aParam     := PARAMIXB
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''          
Local oModel		:= FWModelActive()

  
If aParam <> NIL
      
       oObj       := aParam[1]
       cIdPonto   := aParam[2]
       cIdModel   := aParam[3]
    
		If  cIdPonto == 'MODELPRE'
			xRet       := .T.                    
 	    ElseIf     cIdPonto == 'MODELPOS'
			xRet       := .T.                    
     	ElseIf cIdPonto == 'FORMPRE' 
			cOperacao := aParam[4]    // SETVALUE
			cCampo    := aParam[5] 
			cValor    := aParam[6] 
		       
       	  	xRet       := .T.     
        
        ElseIf cIdPonto == 'FORMPOS'     
       		cOperacao := aParam[4] 
			cCampo    := aParam[5]  
			  
       	   xRet       := .T.     
        
        ElseIf cIdPonto == 'FORMLINEPRE'
        
        	cOperacao := aParam[4] 
			cCampo    := aParam[5] 
			cValor    := aParam[6] 
		
            xRet       := .T.     
       
       ElseIf cIdPonto == 'FORMLINEPOS'
            xRet       := .T.             
       ElseIf cIdPonto == 'MODELCOMMITTTS'
     		xRet       := .T.     
       ElseIf cIdPonto == 'MODELCOMMITNTTS'
     		xRet       := .T.     
       ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
     	    lOperacao := aParam[4] // se .T.(verdadeiro-INCLUSAO) .F. (ALTERACAO/EXCLUSAO)               
			xRet       := .T.     
       ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
     	    lOperacao := aParam[4] // se .T.(verdadeiro -INCLUSAO) .F. (ALTERACAO/EXCLUSAO)               
			xRet       := .T.     
       ElseIf cIdPonto == 'FORMCANCEL'
     		xRet       := .T.
       ElseIf   cIdPonto == 'MODELVLDACTIVE'    
       	 	xRet := .T.  
	   ElseIf cIdPonto == 'MODELCANCEL'
     		xRet       := .T.     
       ElseIf cIdPonto == 'BUTTONBAR'
		  xRet := { {'Rel.Req.Contrato', OemToAnsi("Rel.Req.Contrato"), { || U_SCIR030() }, 'Impressao de Contrato' } }
	   //	aAdd( aRotina, { OemToAnsi("Rel.Req.Contrato")  ,"u_SCIR030" 	,0,7,0 , Nil }	)
       EndIf
EndIf
  
Restarea( aAreaAtu )

Return xRet 
