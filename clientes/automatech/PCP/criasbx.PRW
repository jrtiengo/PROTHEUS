# INCLUDE "PROTHEUS.CH"

USER FUNCTION CRIASBX

Local _cBase := "03"

DbSelectArea("SBQ")
DbSetOrder(1)
DbSeek(xFilial("SBQ")+_cBase)

Do While alltrim(SBQ->BQ_BASE ) == _cBase
   
   _bqChave := SBQ->(BQ_FILIAL+BQ_BASE+BQ_ID)
   _bqID    := SBQ->BQ_ID
   _bqCarac := SBQ->BQ_CARACT

   DbSelectArea("SBS")
   DbSetOrder(1)
   DbSeek(_bqChave)
   
   Do While SBS->(BS_FILIAL+BS_BASE+BS_ID) == _bqChave
      
   	  DbSelectArea("SBX")
   	  
   	  Reclock("SBX",.t.)
   	  BX_FILIAL := xFilial("SBX")
   	  BX_CONJUN := SBS->BS_ID
   	  BX_CODOP  := SBS->BS_CODIGO
   	  BX_DESC   := SBS->BS_DESCR
   	  BX_DESCPR := SBS->BS_DESCPRD
   	  BX_ATIVO  := SBS->BS_ATIVO
      MsUnlock()
      
      DbSelectArea("SBS")
      DbSkip()
   
   Enddo
   
   DbSelectArea("SBW")
   
   Reclock("SBW",.T.)
   BW_FILIAL := xFilial("SBW")
   BW_CONJUN := _bqID
   BW_DESC   := _bqCarac
   MsUnlock()
   
   DbSelectArea("SBQ")
   
   Reclock("SBQ",.f.)
   BQ_TIPDEF := "2"
   BQ_CONJUNT:= _bqID
   MsUnlock()
   
   DbSkip()

Enddo 
      

_cBase := "02"

DbSelectArea("SBQ")
DbSetOrder(1)
DbSeek(xFilial("SBQ")+_cBase)

Do While alltrim(SBQ->BQ_BASE ) == _cBase
   
   
   Reclock("SBQ",.f.)
   BQ_TIPDEF := "2"
   BQ_CONJUNT:= BQ_ID
   MsUnlock()
   
   DbSelectArea("SBQ")
   DbSkip()

Enddo 
Return