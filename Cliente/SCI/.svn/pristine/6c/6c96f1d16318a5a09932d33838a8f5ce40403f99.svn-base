#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³F460MSG   ³ Autor ³ Manoel Mariante       ³ Data ³Jan/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ andamento do contrato,chamado pelo cadastro de contratos   ³±±
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sport Club Internacional						              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function F460VER                    

	Local Area:=GetArea()   
	Local nTamCol:=60               
	Local cLF    :="" //Chr(13)+Chr(10)
	Local cLinha :="" 
	Local aTitulos:={}
	
	//dbSelectArea("SEF")
	//dbSetOrder(1)
	//DbSeek(xFilial("SEF")+"0410100 2616508014000500         ",.t.)
	
	cQuery := "SELECT * "
	cQuery += " FROM " + RetSQLName("SEF") + " SEF"
	cQuery += " WHERE EF_FILIAL = '" + xFilial("SEF") + "'"
	cQuery += " AND EF_BANCO = '"+SEF->EF_BANCO+"'" 
	cQuery += " AND EF_AGENCIA = '"+SEF->EF_AGENCIA+"'"
	cQuery += " AND EF_CONTA = '"+SEF->EF_CONTA+"'"
	cQuery += " AND EF_NUM = '"+SEF->EF_NUM+"'" 
	cQuery += " AND EF_TITULO <> ''"
	cQuery += " AND SEF.D_E_L_E_T_ <> '*'"
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
       	
    cValor  :=PADL(SEF->EF_NUM+SPACE(10)+"#"+ALLTRIM(Str(SEF->EF_VALOR,11,2))+"#",nTamCol)
    cVlrExt :="("+STRTRAN(Extenso(SEF->EF_VALOR),","," ")+")"
    cAuxExt :=Alltrim(cVlrExt)
    aExtenso:={} 
   	//sete mil duzentos
    While !Empty(cAuxExt)
    	nPos    :=AT(" ",cAuxExt)
    	If nPos==0                     
    		cLinha:=cLinha+" "+cAuxExt
    		Exit
    	End
    	cPalavra:=Alltrim(Substr(cAuxExt,1,nPos))
    	
    	If Len(cLinha)+Len(cPalavra) < nTamCol 
    		cLinha:=cLinha+" "+cPalavra
    	Else
    		Aadd(aExtenso,Padr(cLinha,nTamCol," "))
    		cLinha :=""
    	End
    	
    	cAuxExt:=Alltrim(Substr(cAuxExt,nPos+1,400))  
    End                                        
    Aadd(aExtenso,Padr(cLinha,nTamCol," "))
    
    cTitulo:=""   
    cBenef :=""
    cData  :=DTOC(SEF->EF_DATA)
    nCont  :=10
    lVarios:=.F.
    cForneces:=""              
    lEhImposto:=.F.
        
	cString := GETMV('MV_UNIAO')+'/'+GETMV('MV_MUNIC')+'/'+GETMV('MV_FORINSS') 
	
 	WHILE TRB->(!EOF())               
        IF !Empty(cTitulo)
        	cTitulo+=','
        END             
        cAuxTit:=IF(!EMPTY(TRB->EF_TIPO),alltrim(TRB->EF_TIPO)+"-","")+alltrim(TRB->EF_TITULO)+IF(Empty(TRB->EF_PARCELA),"","/"+ALLTRIM(TRB->EF_PARCELA))
        If Len(cTitulo)+Len(cAuxTit) < nTamCol-nCont
  		    cTitulo+=cAuxTit                        
  		    
  		Else
        	Aadd(aTitulos,Padr(cTitulo,nTamCol," "))
        	cTitulo:="" 
        	nCont  :=0
        End
                                     
        If Empty(cForneces)           
        	cForneces:=TRB->EF_FORNECE
        End
        	
        IF !TRB->EF_FORNECE $ cForneces.And.!Empty(cForneces) 
        	lVarios:=.T.
        End      
        
        if  TRB->EF_FORNECE $ cString
        	lEhImposto:=.T.
        End
        cBenef :=alltrim(TRB->EF_BENEF)
    	DBSKIP()
	END   
	
	IF lVarios.oR.lEhImposto
		cBenef:=POSICIONE("SA6",1,XFILIAL('SA6')+SEF->EF_BANCO,'A6_NOME')
	END
		
	Aadd(aTitulos,Padr(cTitulo,nTamCol," "))
	
	cVerso:=Space(nTamCol)+cLF+;
			Space(nTamCol)+cLF+;
			cValor        +cLF+; 
			Space(nTamCol)+cLF 
			
	For nK:=1 to Len(aExtenso)
		cVerso+=aExtenso[nK]+cLF
	Next                      
	
	cVerso+=Space(nTamCol)+cLF        
	
	cVerso+=Padr(cBenef,nTamCol," ")+cLF
	
    cVerso+=Space(nTamCol)+cLF    	

	cVerso+=PADL("PORTO ALEGRE,"+cData,nTamCol," ")+cLF

	cVerso+=Space(nTamCol)+cLF
	
	cVerso+=Padr("PAGTO "+aTitulos[1],nTamCol," ")+cLF
	
	For nK:=2 to Len(aTitulos)
		cVerso+=aTitulos[nK]+cLF
	Next	
			
	TRB->(DbCloseArea())  
	
	//MEMOWRIT('F460VER.txt', cVerso)

Return cVerso