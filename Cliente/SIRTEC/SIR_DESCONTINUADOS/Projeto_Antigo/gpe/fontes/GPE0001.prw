#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPE0001   ºAutor  ³Julio Almeida       º Data ³ 22/09/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a Insalubridade dos funcionarios ligados ao sindi  º±±
±±º          ³ cato "01" SINDIMARMORE                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8 - Gestao de Pessoal                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GPE0001()

//Private 	nPerc     := 0
//Private 	cCodVerba := " "

If SRA->RA_SINDICA = "01" .And. cCodIns # Space(3) .And. SRA->RA_YTIPOF # "N"
	
		
	If fBuscaPD("107") > 0
		nPerc     := 0.10 //fBuscaPD("107","H")
		cCodVerba := "107"
		fDelPD("107")
	EndIf
	
	If fBuscaPD("108") > 0
		nPerc     := 0.20 //fBuscaPD("108","H")
		cCodVerba := "108"
		fDelPD("108")
	EndIf        
	
	If fBuscaPD("109") > 0
		nPerc     := 0.40 //fBuscaPD("109","H")
		cCodVerba := "109"
		fDelPD("109")
	End If

	nDiasTrab := fBuscaPD("101,115","H")
	nValSind  := Posicione("RCE",1, xFilial('RCE') + "01", If(SRA->RA_YTIPOF == "A","RCE_YAJUD","RCE_YPROF")) // Retorna o Valor do Salario da Categoria
	
	fGeraVerba(cCodVerba,((nValSind * nPerc) /30) * nDiasTrab, nPerc,cSemana,SRA->RA_CC,,,,,,.T.) 

End If