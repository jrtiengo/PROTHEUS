#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} MT241SD3
PE usado para gravar o nome do usuario.
@type function
@version Protheus 12.27
@author Eliane Carvalho Barbosa
@since 04/02/2022
/*/
User Function MT241SD3()

  Local aAreaAtu := GetArea()
	Local aAreaSD3 := GetArea("SD3")
	Local cDoc     := SD3->D3_DOC

	DbSelectArea('SD3')
	DbSetOrder(2)
	If DbSeek(xFilial("SD3")+cDoc)

    While !EOF() .and. cDoc == SD3->D3_DOC

      If Empty(SD3->D3_USUARIO)
      
        If !Empty(SD3->D3_USERLGI)
          RecLock('SD3',.F.)
            SD3->D3_USUARIO := FWLEUSERLG("D3_USERLGI")
          MsUnlock()
        Else
          RecLock('SD3',.F.)
            SD3->D3_USUARIO := "Schedule"
          MsUnlock()
        EndIf
      EndIf

      DbSkip()
    Enddo
  
  EndIf

	RestArea(aAreaSD3)
	RestArea(aAreaAtu)

Return()
