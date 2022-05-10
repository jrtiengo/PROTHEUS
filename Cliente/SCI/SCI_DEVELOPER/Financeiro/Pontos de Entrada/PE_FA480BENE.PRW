#Include 'Protheus.ch'
User Function FA480BENE()
   Local cBenef := ''
   dbSelectArea("SA2")
   dbSeek( xFilial("SA2") + SEF->EF_FORNECE + SEF->EF_LOJA )
   cBenef := SA2>A2_NOME
Return cBenef