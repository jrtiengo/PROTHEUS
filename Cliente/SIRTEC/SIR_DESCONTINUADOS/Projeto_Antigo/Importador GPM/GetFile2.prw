#INCLUDE "TOTVS.CH"
 
User Function GetFile2()
    Local cMascara  := "Todos os arquivos|."
    Local cTitulo   := "Escolha o arquivo"
    Local nMascpad  := 0
    Local cDirini   := "\"
    Local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
    Local nOpcoes   := GETF_LOCALHARD
    Local lArvore   := .F. /*.T. = apresenta o árvore do servidor || .F. = não apresenta*/
    Local resourceName:= "totvs.png"
    Local path := "\images\"
    Local fileName:= path + resourceName
    Local targetDir
    Local sucess
 
    targetDir := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)

/*

    If (!Resource2File(resourceName, fileName))
        Alert("Erro ao copiar o arquivo do repositorio!")
    EndIf
 
    If (GetRemoteType() == REMOTE_HTML)
        sucess:= (CpyS2TW(fileName, .T.) == 0)
    Else
        targetDir := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
        sucess:= CpyS2T(fileName, targetDir)
    Endif
 
    If (sucess)
        If (GetRemoteType() == 5)
            Alert("Arquivo ''" + resourceName + "' enviado para download! " + CRLF + "Verifique se o browser nao bloqueou o popup!")
        Else
            Alert("Arquivo ''" + resourceName + "' copiado com sucesso para '" + targetDir + "'!")
        EndIf
    Else
        Alert("Erro ao copiar o arquivo ''" + resourceName + "'!")
    Endif

*/

Return