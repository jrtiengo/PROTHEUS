#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MT107FIL ³ Autor ³        Manoel         ³ Data ³mar/2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Este PE faz o filtro na MATA107 (Lib S.A.) conforme o      ´±±
±±³          ³ parametro  ES_LIBSA.                                       ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
user function MT107FIL()   

	Local cAuxUsrs:= GETMV("ES_LIBSA")      
	Local cAuxUsrs+= AllTrim(SuperGetMV("ES_LIBSA1",.F.,""))   //TARASCONI EM 21/05/2021 CONCATENA MAIS INFORMACOES DE LIBERACAO
	Local aPedaco:={},nPos
	Local cCond:=PARAMIXB[1] 
	Local cCondX:=""
	
	While AT(";",cAuxUsrs)<>0
		nPos    :=AT(";",cAuxUsrs)
		Aadd(aPedaco,Left(cAuxUsrs,nPos-1) )
		cAuxUsrs:=Substr(cAuxUsrs,nPos+1)
	End
	
	Aadd(aPedaco,cAuxUsrs)
	
	cUserLog := RetCodUsr()
	
	For nK:=1 to Len(aPedaco)
		nPos   :=AT("=",aPedaco[nK])   
		cUser  :=Left(aPedaco[nK],nPos-1)
		cLocais:=Substr(aPedaco[nK],nPos+1)
			
		IF cUserLog $ cUser 
			IF Empty(cCondX)                          
				cCondX+=" CP_LOCAL='"+cLocais+"'"
			Else
				cCondX+=" .OR. CP_LOCAL='"+cLocais+"'"
			End
		End		
	Next                      
	If Empty(cCondX)
		cCondX:="1=2" 
		Alert('Usuario sem acesso a liberação de S.A.'+Chr(13)+Chr(10)+;
		      'Nenhuma S.A. será mostrada')
	End
	cCond:=cCond+" .AND. ("+cCondX+")"
	
Return cCond
