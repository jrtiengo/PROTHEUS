#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include "Totvs.ch"
#Include 'parmtype.ch'
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} SIRA011
Rotina chamada pelo PE GPE10BTN.
Para visualisar/excluir, um documento por matrícula,
pdf no diretório de conhecimento.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function SIRA011(nOpc)

    Private cSPath_     := GetMv("MV_DIRDOC")+"\co"+cEmpAnt+"\shared\treinamentos\"

    /*
    If !Empty(Alltrim(nome_arq))
        SIRA011A()
    Else
        SIRA011E()
    EndIf
    */

    If cEstou <> "03"
        MsgAlert("Opção disponível apenas para Cursos!", "Atenção!")
        Return()
    EndIf

    If nOpc == 1
        SIRA011A()
    ElseiF nOpc == 2
        SIRA011E()
    EndIf

Return()



/*/{Protheus.doc} SIRA011A
Static responsável pela abertura do documento.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function SIRA011A()

    Local nPos_     := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="RA4_ARQTRN"})
    Local cArq_     := Alltrim(aCols[n][nPos_])
    Local nRet      := 0
    local cRet      := GetTempPath()

    If lRet := CpyS2T( cSPath_ + cArq_ , cRet, .F. )

        //Tentando abrir o objeto
        nRet := ShellExecute("open", cArq_, "", cRet, 1)
        
        //Se houver algum erro
        If nRet <= 32
            MsgStop("Não foi possível abrir o arquivo " +  cArq_ + "!", "Atenção")
        EndIf 

    EndIf
  

Return()



/*/{Protheus.doc} SIRA011E
Static responsável por pegar os dados para gerar a lista.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function SIRA011E()

    Local nPos_     := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="RA4_ARQTRN"})
    Local cArq_     := Alltrim(aCols[n][nPos_])
    Local aArea     := GetArea()

 
	
    //Apaga arquivo físico.
    If File(cSPath_ + cArq_ )
        If !MsgYesNo("Você tem certeza que deseja apagar o(s) aqruivo(s) de selecionado(s)?")
            RestArea(aArea)
		    Return()
        Else
            If fErase(cSPath_ + cArq_) == 0

                DbSelectArea("RA4")
                DbSetOrder(1)
                If DbSeek(xFilial("RA4")+SRA->RA_MAT+aCols[n][3])
                    RecLock("RA4",.F.)
                    RA4->RA4_ARQTRN := Space(20)
                    aCols[n][7]     := Space(20)
                    MsUnlock()
                EndIf

            EndIf
        EndIf
    Else
        MsgAlert("Não foi possvel apagar o arquivo "+cArq_+".pdf"+". Por favor, verifique!")
    EndIf

    RestArea(aArea)

Return()

