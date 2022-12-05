#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GP650CPO  ºAutor  ³ Reiner            º Data ³  05/03/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava natureza do centro de custo                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Calabria                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GP650CPO() 

Local aArea    := GetArea()
Local aAreaCTT	:= CTT->(GetArea())
Local aAreaRC1	:= RC1->(GetArea())
Local aAreaRC0	:= RC0->(GetArea())
Local aAreaSRA	:= SRA->(GetArea())
Local cCC      := Space(09) 
Local cNat     := Space(10)

// Se for RC0_AGRUPA = "4" pega RC1_MAT
// Se for RC0_AGRUPA = "2" pega RC1_CC
// Se diferente de agrupa=4, sai da rotina.

// Ponto de entrada vai rodar apenas na empresa 10
// Para inserir outras (criar campo CTT_NATURE e tratar no If abaixo
// --------------------------------
// NA EMPRESA 85 NAO EXISTE A NATUREZA NA TABELA CTT
// --------------------------------
If cEmpAnt <> "10" 
   Return
ElseIf cEmpAnt = "10" .And. !(RC1->RC1_FILIAL $ "04|06")  // If !("a"$"cde")
   Return 
Endif   

Dbselectarea("RC0") 
Dbsetorder(1)
Dbseek(xFilial("RC0") + RC1->RC1_CODTIT, .F.)
If (RC0->RC0_AGRUPA $ "2|4")
   If RC0->RC0_AGRUPA = "4"

      Dbselectarea("SRA") 
      Dbsetorder(1)
      Dbseek(xFilial("SRA") + RC1->RC1_MAT, .F.)
      cCC := SRA->RA_CC
   Else
      cCC := RC1->RC1_CC
   Endif

   Dbselectarea("CTT")    
   Dbsetorder(1)
   If Dbseek(xFilial("CTT") + cCC, .F.) 
      cNat := CTT->CTT_NATURE  
   Else
      Msgstop('Nao encontrou o Centro de Custos ' + cCC + ' no Cadastro de Centro de Custos.') 

      RestArea(aArea)
      RestArea(aAreaCTT)
      RestArea(aAreaRC0)
      RestArea(aAreaSRA) 
      
      Return
   Endif                                                                          

   Dbselectarea("RC1")
   RecLock("RC1",.F.)
      RC1->RC1_NATURE   := cNat
   MsUnlock()
EndIf   

RestArea(aArea)
RestArea(aAreaCTT)
RestArea(aAreaRC0)
RestArea(aAreaRC1)
RestArea(aAreaSRA)

Return

