#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} 
PE usado para gravar o nome do usuario.
@type function
@version Protheus 12.27
@author Eliane Carvalho Barbosa
@since 04/02/2022
@return nil
/*/

User Function MT241SD3()

Local aAreaAtu := GetArea()
Local aAreaSD3 := GetArea("SD3")
Local cDoc:=''

cDoc:=SD3->D3_DOC
DbSelectArea('SD3')
DbSetOrder(2)
DbSeek(xFilial("SD3")+cDoc)


While !EOF() .and. cDoc == SD3->D3_DOC
  //MsgYesNo("Gravar nome do usuario ","Atencao")

  If Empty(SD3->D3_USUARIO).AND.!Empty(D3_USERLGI)
    RecLock('SD3',.F.)
      SD3->D3_USUARIO:=FWLEUSERLG("D3_USERLGI")
    MsUnlock()
  EndIf
  DbSkip()
	
Enddo

RestArea(aAreaSD3)
RestArea(aAreaAtu)

Return()
