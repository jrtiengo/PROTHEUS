#include 'protheus.ch'
#include 'parmtype.ch'


User function mostra_fonte()

	Local aFontes := {}
	Local nI , nT
	Local cFile := "C:\temp\LogRPO.txt" 
	Local nH 

	nH := fCreate(cFile) 
	If nH == -1 
		MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
		Return 
	Endif 



	aFontes := GetSrcArray("*.PRW") 
	nT := len(aFontes)
	If nT > 0
		For nI := 1 to nT
			aData := GetAPOInfo(aFontes[nI])
			If "BUILD_USER" $ Alltrim(aData[3])
				// Escreve o texto mais a quebra de linha CRLF
				fWrite(nH, "Fonte; "+aData[1]+";"+aData[2]+";"+aData[3]+";"+dtoc(aData[4]) + chr(13)+chr(10) )
			EndIf
		Next
		MsgInfo("Fontes encontrados. Verifique log de console.",cFile)
	Else
		MsgAlert("Nenhum fonte encontrado.")
	Endif

	fClose(nH)

Return
