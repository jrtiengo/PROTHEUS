#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ» ±±
±±ºPrograma  ³ULTNUM ºAutor  ³Alessandro Minussi     º Data ³  04/12/09   º ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹ ±±
±±ºDesc.     ³Programa para Verificar Ultimo numero  º±±
±±º          ³e sua sequencia                                               ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹ ±±
±±ºUso       ³                                                     º ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß±
*/

User Function ULTNUMCTR()
    Local _cArea:=GetArea()
	Local cQuery                 
    cNumprox := ""
        
	// Verifica o NUMERO do ultimO 
	cQuery := " SELECT max(substring(CN9_NUMERO,1,3)) MNUM "
	cQuery += " FROM " + RetSQLName("CN9") + " CN9 "         
	cQuery += " WHERE CN9_FILIAL       = '" + xFilial("CN9") + "'"
	cQuery += " AND CN9_AREA           = '" + ALLTRIM(M->CN9_AREA)+"'" 
	//cQuery += " AND LEFT(CN9_DTINIC,4) = '" + LEFT(DTOS(dDataBase),4)+"'" 
	cQuery += " AND SUBSTRING(CN9_NUMERO,9,2) = '" + substr(DTOS(dDataBase),3,2)+"'"
	cQuery += " AND CN9.D_E_L_E_T_ <> '*' "    
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TZC1",.F.,.T.)
	DbSelectArea("TZC1")
	DbGoTop()
	
	IF !Eof() .And. !Empty(TZC1->MNUM)
	  	cNumprox:= Soma1(TZC1->MNUM)   
	Else	
		cNumprox := "001"	  			  
	Endif                    
    	
	TZC1->( DbCloseArea() )

//	cNumprox:= ALLTRIM(M->CN9_AREA) + cNumprox + "/" + STRZERO(YEAR(DDATABASE),4) - a pedido do juridico foi alterada a ordem da composição do numero do contrato.  
	
	cNumprox:= cNumprox +"/"+ ALLTRIM(M->CN9_AREA) +"/"+ substr(DTOS(DDATABASE),3,2)   
	
    RestArea(_cArea)
    
Return(cNumProx)