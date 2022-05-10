#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} 
PE usado para validar o CC informado pelo usuario.
@type function
@version Protheus 12.33
@author Eliane Carvalho Barbosa
@since 04/03/2022
@return nil
/*/

User Function MT241TOK() 

Local lRet			:= .T.
Local aArea		    := GetArea()
Local aAreaSD3      := GetArea("SD3")
Local aAreaSB1      := GetArea("SB1")
Local aAreaCTQ      := GetArea("CTQ")
Local nI			:= 0
Local nPosCod		:= aScan(aHeader, {|x| ALLTRIM(x[2]) == "D3_COD"})
Local ltipo:= .F.
Local cCCCTQ:= '' 
Local cProduto:= '' 

If IsInCallStack("MATA241") .and. !Empty(CCC)
	
  For nI := 1 To Len(aCols)
	If !aCols[nI][Len(aHeader) + 1]
      cProduto:=aCols[nI][nPosCod]
      dbSelectArea("SB1")
	  SB1->(dbSetOrder(1))
	  SB1->(dbGoTop())
	 If SB1->(dbSeek(xFilial("SB1") + cProduto))

	   If SB1->B1_TIPO =='PA' .or.  SB1->B1_TIPO=='PI'
		 ltipo := .T.
	    EndIf
       EndIf
	 EndIf
  Next nI

   If  ltipo == .T.

     dbSelectArea("CTQ")
	 CTQ->(dbSetOrder(7))
	 CTQ->(dbGoTop())
	 If CTQ->(dbSeek(xFilial("CTQ") + CCC))
       cCCCTQ:=CTQ->CTQ_CCPAR    
     EndIf

     If !Empty(cCCCTQ) 
	    lRet := .F.
	    MsgAlert("Atenção! Centro de Custo " + cCCCTQ + " de rateio offline não é permitido em movimentos com produtos do tipo PA ou PI")
     EndIf
    EndIf
Endif

RestArea(aAreaCTQ)
RestArea(aAreaSB1)
RestArea(aAreaSD3)
RestArea(aArea)

Return lRet
