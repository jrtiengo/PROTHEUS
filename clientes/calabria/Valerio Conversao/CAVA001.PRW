#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CAVA001     บ Autor ณ Valerio         บ Data ณ  19/03/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Troca de centros de custo                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Calabria                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CAVA001
Private aaTabe := {}
Private aaDePa := {}
Private ccLog  := ""    
Private cEOL    := CHR(13)+CHR(10)

LeCSV01() // Le csv das tabelas  
LeCSV02() // Le csv dos CCs
Grava()   // Executa De Para

Return
                         
 
//---------------------//
Static Function LeCSV01()
ccArq := "\data\temp\tabe10.csv"   
nHandle := FT_FUse(ccArq)
if nHandle = -1
	Msgstop("Erro na abertura do arquivo das tabelas (tabe10.csv)")
	Return
endif
FT_FGoTop()
nLast  := FT_FLastRec()
nnLido := 0
While !FT_FEOF()
	nnLido 	:= nnLido + 1
	cLine 	:= FT_FReadLn() 						// Retorna a linha corrente
	nRecno	:= FT_FRecno() 							// Retorna o recno da Linha      
	aRet    := StrTokArr(cLine,";") 				// Resultado: aRet[1]="Primeiro" / aRet[2]="Segundo" / aRet[3]="Terceiro"    
	ccTab   := aRet[01]
	ccCam   := aRet[02]      
    aadd(aaTabe,{ccTab,ccCam})
	FT_FSKIP()
End
FT_FUSE()
Return


//---------------------//
Static Function LeCSV02()
ccArq := "\data\temp\ccs10.csv"   
nHandle := FT_FUse(ccArq)
if nHandle = -1
	Msgstop("Erro na abertura do arquivo DEPARA (ccs10.csv)")
	Return
endif
FT_FGoTop()
nLast  := FT_FLastRec()
nnLido := 0
While !FT_FEOF()
	nnLido 	:= nnLido + 1
	cLine 	:= FT_FReadLn() 						// Retorna a linha corrente
	nRecno	:= FT_FRecno() 							// Retorna o recno da Linha      
	aRet    := StrTokArr(cLine,";") 				// Resultado: aRet[1]="Primeiro" / aRet[2]="Segundo" / aRet[3]="Terceiro"    
	ccDe     := aRet[01]
	ccPara   := aRet[02]      
	ccFil    := aRet[03]
    aadd(aaDePa,{ccFil,ccDe,ccPara})
	FT_FSKIP()
End
FT_FUSE() 
Return
                           

//-------------------//
Static Function Grava()  
Private cArqLog := "\data\temp\log.txt"
Private nArqLog := fCreate(cArqLog)   
nnvazio := 0
nncheio := 0
 
For i = 1 to Len(aaTabe)
	ccTab  := aaTabe[i,1]
	ccCam  := aaTabe[i,2]
	If Substr(ccCam,3,1) = "_"
		ccCaF  := Substr(ccCam,1,3) + "FILIAL"
	Endif
	If Substr(ccCam,4,1) = "_"
		ccCaF  := Substr(ccCam,1,4) + "FILIAL"
	Endif  
	If ccCam <> "VAZIO"
	    nncheio := nncheio + 1
		For y = 1 to Len(aaDePa)
			ccFil  := aaDePa[y,1]
			ccDe   := aaDePa[y,2]
			ccPara := aaDePa[y,3]
			cQuery := " UPDATE " + ccTab + "100 SET " + ccCam + " = '" + ccPara + "'"
			cQuery += " WHERE "  + ccCam + " = '" + ccDe  + "'"
			cQuery += " AND "    + ccCaF + " = '" + ccFil + "'"    
			TCSQLExec( cQuery ) 
			nTamLin := 2     
			cLin    := Space(nTamLin)+cEOL      
			cLin    := Stuff(cLin,01,02,cQuery)
			If fWrite(nArqLog,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do log.","Atencao!")
					//Return
				Endif
			Endif
		Next y     
    Else
	    nnVazio := nnVazio + 1
	Endif
Next i           
msgstop("Tabelas com CC = " + str(nnCheio,5) + "  vazio = " + str(nnvazio,5))

Return

    

