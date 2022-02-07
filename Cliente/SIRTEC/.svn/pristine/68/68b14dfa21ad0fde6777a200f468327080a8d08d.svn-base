#INCLUDE 'PROTHEUS.CH'

// Função que rejeita produtos da SA caso motivo selecionado for 8

User Function MT105FIM()

   Local nContar   := 0
   Local _nProduto := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_PRODUTO" })
   Local _nItem    := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_ITEM"    })
   Local _nNumero  := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_NUM"     })
   Local _nMotivo  := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_MOTI"    })
   
   For nContar = 1 to Len(aCols)

	   // Posiciona-se no item da SA
	   dbSelectArea("SCP")
	   dbSetOrder(2)
   	   If dbSeek(xFilial("SCP") + aCols[nContar][_nProduto] + SCP->CP_NUM + aCols[nContar][_nItem])
	      RecLock("SCP", .F.)
   	      If aCols[nContar][_nMotivo] == "8"
             SCP->CP_STATSA := "R"
          Else
             SCP->CP_STATSA := ""
          Endif
		  SCP->(MsUnLock())                
       Endif

   Next nContar
   
Return 