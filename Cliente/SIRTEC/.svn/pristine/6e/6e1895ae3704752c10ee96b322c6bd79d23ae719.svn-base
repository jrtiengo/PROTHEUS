#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include "Totvs.ch"
#Include 'parmtype.ch'
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} SIRA010
Rotina via consulta padrão.
Para icluir documento de treinamento por matrícula.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function SIRA010()

    Local cDir_         := ""
    Local cRet_         := ""
    Local lRet_         := .F.
    Local nPos_         := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="RA4_CURSO"})
    Private cSPath_     := GetMv("MV_DIRDOC")+"co"+cEmpAnt+"\shared\treinamentos\"
    Private nome_arq	:= Alltrim(SRA->RA_MAT)+"."+ cEmpAnt+cFilAnt+"."
    Private cCurso_     := aCols[n][nPos_] // RA4_CURSO
    Public __cResult    := ""
 
    cDir_       := cGetFile("Arquivo de Treinamento |*.pdf", "Selecione o Documento do Curso.")

    If Alltrim(cDir_) <> ""

        If File(cSPath_+nome_arq+cCurso_+".pdf")

            If !MsgYesNo("Arquivo já existe. Deseja substiuir?", "Atenção!")
                Return(lRet_)
            EndIf

        EndIf

        cRet_ := nome_arq+cCurso_+".pdf"
        __CopyFile(cDir_,cSPath_+ cRet_)
        __cResult := cRet_

        //Se tiver resultado, prossegue como verdadeiro o retorno
        If ! Empty(__cResult)
            //Tira espaços em branco e o -Enter-
            __cResult := StrTran(__cResult, Chr(10))
            __cResult := StrTran(__cResult, Chr(13))
            __cResult := Alltrim(__cResult)
            lRet_ := .T.

        EndIf

  
    EndIf

    
Return(lRet_)

