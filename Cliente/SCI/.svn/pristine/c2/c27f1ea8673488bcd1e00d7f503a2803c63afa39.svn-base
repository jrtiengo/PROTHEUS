#INCLUDE "protheus.ch"

User Function CN120NPG()  

LOCAL AREA:=GETAREA()  
LOCAL cNovaNat:=PARAMIXB[1]
LOCAL cOrigNat:='MV_CNNAT'
LOCAL cPRODUTO:='               '

dbSelectArea("CNB")
dbSetOrder(1)          
dbSeek(CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO),.T. )

cPRODUTO:=CNB->CNB_PRODUT

dbSelectArea("SB1")
dbSetOrder(1)          
dbSeek(SB1->(xFilial("SB1")+cPRODUTO),.T. )
IF (SB1->B1_ALIQISS>0)
  
  /*
  //Alert(SB1->B1_COD+"CODIGO")
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_ALIQISS")
	RECLOCK("SX6",.F.)
  //Alert(STR(SB1->B1_ALIQISS)+"ALIQ")
	sx6->x6_conteud:=ALLTRIM(STR(SB1->B1_ALIQISS))
	MsUnlock()
   */
   PutMv("MV_ALIQISS",ALLTRIM(STR(SB1->B1_ALIQISS)))


END	                    

 
   

IF EMPTY(CNB->CNB_NATURE)
	IF ! EMPTY(CN9->CN9_NATURE)
		/*
		cNovaNat:=CN9->CN9_NATURE 
		cOrigNat:='CN9'
		dbSelectArea("SX6")
		dbSetOrder(1)
		dbSeek(xFilial("SX6")+"MV_CNNAT")
		RECLOCK("SX6",.F.)
		sx6->x6_conteud:=cNovaNat
		MsUnlock()  
		*/
	   PutMv("MV_CNNAT",cNovaNat)
		
		
	END
ELSE
	/*
	cNovaNat:=CNB->CNB_NATURE    
	cOrigNat:='CNB'
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_CNNAT")
	RECLOCK("SX6",.F.)
	sx6->x6_conteud:=cNovaNat
	MsUnlock()       
	//alert('chave '+CND->(CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO))
	*/
	PutMv("MV_CNNAT",cNovaNat)
END

 

IF EMPTY(CN9->CN9_CLIENT)
	/*
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_CNNAT")
	RECLOCK("SX6",.F.)
	sx6->x6_conteud:=cNovaNat
	MsUnlock()  
    */
    PutMv("MV_CNNAT",cNovaNat)
    
    /*
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_CNNATCL")
	RECLOCK("SX6",.F.)
	sx6->x6_conteud:=cNovaNat
	MsUnlock()  
	*/
	PutMv("MV_CNNATCL",cNovaNat)
	
ELSE
	/*
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_CNNAT")
	RECLOCK("SX6",.F.)
	sx6->x6_conteud:=cNovaNat
	MsUnlock()  
    */
    PutMv("MV_CNNAT",cNovaNat)

	/*
	dbSelectArea("SX6")
	dbSetOrder(1)
	dbSeek(xFilial("SX6")+"MV_CNNATCL")
	RECLOCK("SX6",.F.)
	sx6->x6_conteud:=cNovaNat
	MsUnlock()  
	*/
	PutMv("MV_CNNATCL",cNovaNat)
END
//alert('alterei o parametro '+sx6->x6_var)
dbSelectArea('CN9')
Reclock('CN9',.f.)
CN9->CN9_NATURE:=cNovaNat
msunlock()             

//alert('alterei o parametro '+cnovanat)

RESTAREA(AREA)

Return cNovaNat
